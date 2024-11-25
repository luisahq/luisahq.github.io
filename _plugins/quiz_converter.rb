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

    def convert_question (question, qzn, qn)
      fieldset = Kramdown::Element.new :html_element
      fieldset.value = 'fieldset'
      fieldset.attr['id'] = 'quiz' + qzn.to_s + 'q' + qn.to_s
      legend = Kramdown::Element.new :html_element
      legend.value = 'legend'
      legend.children = [Kramdown::Element.new(:text, question['question'])]
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
          choice_text = choice.instance_of?(String) ? choice : choice.to_s
          label.children = [Kramdown::Element.new(:text, choice_text)]
          fieldset.children << input << label << Kramdown::Element.new(:br)
          a += 1
        end
      end

      fieldset
    end

    def convert_quiz (quiz, node, qzn)
      node.type = :html_element
      node.value = 'form'
      node.attr['id'] = 'quiz' + qzn.to_s
      node.attr['class'] = 'quiz'
      node.attr['action'] = ''
      node.attr['method'] = 'get'
      topic = Kramdown::Element.new :html_element
      topic.value = 'div'
      topic.attr['class'] = 'quiz-topic'
      topic_text = (quiz.has_key?('topic') ? quiz['topic'] + ' ' : '') + 'Quiz'
      topic.children = [Kramdown::Element.new(:text, topic_text)]
      node.children = [topic]
      qn = 1

      quiz['questions'].each do |question|
        node.children << convert_question(question, qzn, qn)
        qn += 1
      end

      submit = Kramdown::Element.new :html_element
      submit.value = 'button'
      submit.attr['type'] = 'button'
      submit.children = [Kramdown::Element.new(:text, 'Submit')]
      node.children << submit
    end

    def convert_quizzes (node, qzn)
      if node.type == :codeblock && node.options[:lang] == 'quiz'
        quiz = PerfectTOML.parse node.value
        normalize_quiz quiz
        convert_quiz quiz, node, qzn
        qzn += 1
      end

      node.children.each do |child|
        convert_quizzes child, qzn
      end
    end

    def convert (content)
      qzn = 1
      doc = Kramdown::Document.new content, input: 'GFM'
      convert_quizzes doc.root, qzn
      doc.to_html
    end
  end
end
