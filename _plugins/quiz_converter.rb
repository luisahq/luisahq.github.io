require 'perfect_toml'

module Jekyll
  class QuizConverter < Converter
    safe true
    priority :highest

    def matches (ext)
      ext =~ /^\.md$/i
    end

    def output_ext (ext)
      '.html'
    end

    def normalize_question_type (question)
      if !question.has_key? 'type'
        raise 'Question must have a type.'
      end

      question['type'] = question['type'].delete(' ').downcase

      if question['type'] != 'shortanswer' &&
         question['type'] != 'multiplechoice'
        raise 'Question type must be either short answer or multiple choice.'
      end
    end

    def is_bool? (object)
      object.is_a?(TrueClass) || object.is_a?(FalseClass)
    end

    def normalize_question (question)
      if !question.instance_of? Hash
        raise 'Question must be a table.'
      end

      if !question.has_key? 'question'
        raise 'Question must have a "question" key.'

        if !question['question'].instance_of? String
          raise 'Question must be a string.'
        end
      end

      if question.has_key? 'context'
        if !question['context'].instance_of? String
          raise 'Context must be a string.'
        end
      end

      normalize_question_type question

      if question['type'] == 'shortanswer'
        if !question.has_key? 'answer'
          raise 'Short answer question must have an "answer" key.'
        end

        if question.has_key?('ci') && !is_bool?(question['ci'])
          raise 'ci must be a boolean.'
        end

        if question.has_key?('fuzz') && !question['fuzz'].is_a?(Numeric)
          raise 'Fuzz factor must be a number.'
        end
      end

      if question['type'] == 'multiplechoice'
        if !question.has_key? 'choices'
          raise 'Multiple choice question must have a "choices" key.'
        end

        if !question['choices'].instance_of? Array
          raise 'Choices must be an array.'
        end

        question['choices'].each do |choice|
          if !choice.instance_of? String
            raise 'Multiple choice option must be a string.'
          end
        end

        if !question.has_key?('answer') && !question.has_key?('answers')
          raise 'Multiple choice question must have an "answer[s]" key.'
        end

        if question.has_key?('answer') && question.has_key?('answers')
          raise 'Multiple choice question must have cannot have both "answer"'\
                'and "answers" keys.'
        end

        if question.has_key? 'answer'
          if !question['answer'].is_a? Integer
            raise 'Multiple choice answer must be an integer.'
          end
        else
          if !question['answers'].instance_of? Array
            raise 'Answers must be an array.'
          end

          question['answers'].each do |answer|
            if !answer.is_a? Integer
              raise 'Multiple choice answer must be an integer.'
            end
          end
        end
      end
    end

    def normalize_quiz (quiz)
      if !quiz.has_key? 'questions'
        raise 'Quiz does not have any questions.'
      end

      if !quiz['questions'].instance_of? Array
        raise 'Questions must be an array.'
      end

      quiz['questions'].each do |question| normalize_question question end
    end

    def text_to_ast (text)
      Kramdown::Document.new(text, input: 'GFM').root.children[0].children
    end

    def convert_question (question, qzn, qn)
      fieldset = Kramdown::Element.new :html_element
      fieldset.value = 'fieldset'
      fieldset.attr['id'] = 'quiz' + qzn.to_s + 'q' + qn.to_s
      legend = Kramdown::Element.new :html_element
      legend.value = 'legend'
      qn_el = Kramdown::Element.new :strong
      qn_el.children = [Kramdown::Element.new(:text, qn.to_s + '. ')]
      legend.children = [qn_el]

      text_to_ast(question['question']).each do |node|
        legend.children << node
      end

      fieldset.children = [legend]

      if question['type'] == 'shortanswer'
        input = Kramdown::Element.new :html_element
        input.value = 'input'
        input.attr['type'] = 'text'
        fieldset.children << input
      else
        qid = 'quiz' + qzn.to_s + 'q' + qn.to_s
        type = question.has_key?('answer') ? 'radio' : 'checkbox'
        a = 1

        question['choices'].each do |choice|
          input = Kramdown::Element.new :html_element
          input.value = 'input'
          id = qid + 'a' + a.to_s
          input.attr['type'] = type
          input.attr['id'] = id
          input.attr['name'] = qid
          label = Kramdown::Element.new :html_element
          label.value = 'label'
          label.attr['for'] = id
          label.children = text_to_ast(choice)
          fieldset.children << input << label << Kramdown::Element.new(:br)
          a += 1
        end
      end

      fieldset
    end

    def convert_quiz (quiz, node, qzn)
      node.type = :html_element
      node.value = 'div'
      node.attr['id'] = 'quiz' + qzn.to_s
      node.attr['class'] = 'quiz'
      topic = Kramdown::Element.new :html_element
      topic.value = 'div'
      topic.attr['class'] = 'quiz-topic'
      topic_text = (quiz.has_key?('topic') ? quiz['topic'] + ' ' : '') + 'Quiz'
      topic.children = [Kramdown::Element.new(:text, topic_text)]
      node.children = [topic]
      start_btn = Kramdown::Element.new :html_element
      start_btn.value = 'button'
      start_btn.attr['type'] = 'button'
      start_btn.attr['class'] = 'quiz-start-button'
      start_btn.attr['disabled'] = true
      start_btn.children = [Kramdown::Element.new(:text, 'JavaScript required')]
      node.children << start_btn
      form = Kramdown::Element.new :html_element
      form.type = :html_element
      form.value = 'form'
      form.attr['action'] = ''
      form.attr['method'] = 'get'
      form.attr['class'] = 'hidden'
      qn = 1

      quiz['questions'].each do |question|
        form.children << convert_question(question, qzn, qn)
        qn += 1
      end

      submit = Kramdown::Element.new :html_element
      submit.value = 'button'
      submit.attr['type'] = 'button'
      submit.children = [Kramdown::Element.new(:text, 'Submit')]
      form.children << submit
      node.children << form
    end

    def convert_quizzes (node, qzn)
      if node.type == :codeblock && node.options[:lang] == 'quiz'
        quiz = PerfectTOML.parse node.value
        normalize_quiz quiz
        qzn += 1
        convert_quiz quiz, node, qzn
      end

      node.children.each do |child|
        qzn = convert_quizzes child, qzn
      end

      qzn
    end

    def convert (content)
      qzn = 0
      doc = Kramdown::Document.new content, input: 'GFM'
      qzn = convert_quizzes doc.root, qzn

      if qzn > 0
        link = Kramdown::Element.new :html_element
        link.value = 'link'
        link.attr['stylesheet'] = 'rel'
        link.attr['href'] = '/assets/quiz.css'
        doc.root.children << link
      end

      doc.to_html
    end
  end
end
