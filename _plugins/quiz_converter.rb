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

      type = question['type'].split.filter{ |s| s != '' }

      if type.size > 1
        question['type'] = type.map{ |s| s[0].downcase }.join
      else
        question['type'] = type[0]
      end

      if question['type'] != 'sa' &&
         question['type'] != 'mc' &&
         question['type'] != 'ma'
        raise 'Question type must be either short answer, multiple choice, or '\
              'multiple answer.'
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

      if !question.has_key? 'answer'
        raise 'Question must have an "answer" key.'
      end

      if question['type'] == 'sa'
        if !question['answer'].instance_of? String
          raise 'Short answer answer must be a string.'
        end

        if question.has_key?('ci') && !is_bool?(question['ci'])
          raise 'ci must be a boolean.'
        end

        if question.has_key?('fuzz') && !question['fuzz'].is_a?(Numeric)
          raise 'Fuzz factor must be a number.'
        end
      end

      if question['type'] == 'mc' || question['type'] == 'ma'
        if !question.has_key? 'choices'
          raise 'Multiple choice/answer question must have a "choices" key.'
        end

        if !question['choices'].instance_of? Array
          raise 'Choices must be an array.'
        end

        question['choices'].each do |choice|
          if !choice.instance_of? String
            raise 'Choice must be a string.'
          end
        end

        if question['type'] == 'mc' && !question['answer'].is_a?(Integer)
            raise 'Multiple choice answer must be an integer.'
        end

        if question['type'] == 'ma'
          if !question['answer'].instance_of? Array
            raise 'Multiple answer question answer must be an array.'
          end

          question['answer'].each do |answer|
            if !answer.is_a? Integer
              raise 'Multiple answer question answer must only have integers.'
            end
          end
        end
      end
    end

    def normalize_quiz (quiz)
      if !quiz.has_key? 'questions'
        raise 'Quiz must have at least one question.'
      end

      if !quiz['questions'].instance_of? Array
        raise 'Questions must be an array.'
      end

      quiz['questions'].each do |question| normalize_question question end
    end

    def parse_markdown (text)
      Kramdown::Document.new(text, { input: 'GFM' })
    end

    def parse_inlines (text)
      parse_markdown(text).root.children[0].children
    end

    def parse_blocks (text)
      parse_markdown(text).root.children
    end

    def convert_question (question, qzn, qn, qs_size)
      fieldset = Kramdown::Element.new :html_element
      fieldset.value = 'fieldset'
      fieldset.attr['id'] = 'quiz' + qzn.to_s + 'q' + qn.to_s
      fieldset.attr['data-question-type'] = question['type']

      if question['type'] == 'sa'
        fieldset.attr['data-answer'] = question['answer']
      elsif question['type'] == 'mc'
        fieldset.attr['data-answer'] = question['answer'].to_s
      else
        fieldset.attr['data-answer'] = question['answer']
          .map{ |n| n.to_s }
          .join(',')
      end

      legend = Kramdown::Element.new :html_element
      legend.value = 'legend'
      legend.attr['align'] = 'right'

      legend.children = [
        Kramdown::Element.new(
          :text,
          'Question ' + qn.to_s + ' / ' + qs_size.to_s
        )
      ]

      q_el = Kramdown::Element.new :html_element
      q_el.value = 'div'
      q_el.attr['class'] = 'quiz-question'

      parse_blocks(question['question']).each do |node|
        q_el.children << node
      end

      fieldset.children = [legend, q_el]

      if question['type'] == 'sa'
        input = Kramdown::Element.new :html_element
        input.value = 'input'
        input.attr['type'] = 'text'
        fieldset.children << input
      else
        qid = 'quiz' + qzn.to_s + 'q' + qn.to_s
        a = 1

        question['choices'].each do |choice|
          input = Kramdown::Element.new :html_element
          input.value = 'input'
          id = qid + 'a' + a.to_s
          input.attr['type'] = question['type'] == 'mc' ? 'radio' : 'checkbox'
          input.attr['id'] = id
          input.attr['name'] = qid
          label = Kramdown::Element.new :html_element
          label.value = 'label'
          label.attr['for'] = id
          label.children = parse_inlines choice
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
      start = Kramdown::Element.new :html_element
      start.value = 'div'
      start.attr['class'] = 'quiz-start'
      qsn = Kramdown::Element.new :html_element
      qsn.value = 'div'
      qsn.attr['class'] = 'quiz-questions-number'

      qsn.children = [
        Kramdown::Element.new(:text, quiz['questions'].size.to_s + ' questions')
      ]

      start_btn = Kramdown::Element.new :html_element
      start_btn.value = 'button'
      start_btn.attr['type'] = 'button'
      start_btn.attr['class'] = 'quiz-start-button'
      start_btn.attr['disabled'] = true
      start_btn.children = [Kramdown::Element.new(:text, 'JavaScript required')]
      start.children = [start_btn, qsn]
      node.children = [topic, start]
      form = Kramdown::Element.new :html_element
      form.type = :html_element
      form.value = 'form'
      form.attr['action'] = ''
      form.attr['method'] = 'get'
      qn = 1

      quiz['questions'].each do |question|
        form.children <<
          convert_question(question, qzn, qn, quiz['questions'].size)
        qn += 1
      end

      quiz_end = Kramdown::Element.new :html_element
      quiz_end.value = 'div'
      quiz_end.attr['class'] = 'quiz-end'
      score = Kramdown::Element.new :html_element
      score.value = 'div'
      score.attr['class'] = 'quiz-end-score'
      quiz_end_buttons = Kramdown::Element.new :html_element
      quiz_end_buttons.value = 'div'
      quiz_end_buttons.attr['class'] = 'quiz-end-buttons'
      submit = Kramdown::Element.new :html_element
      submit.value = 'button'
      submit.attr['type'] = 'button'
      submit.attr['class'] = 'quiz-submit-button'
      submit.children = [Kramdown::Element.new(:text, 'Submit')]
      cancel = Kramdown::Element.new :html_element
      cancel.value = 'button'
      cancel.attr['type'] = 'button'
      cancel.attr['class'] = 'quiz-cancel-button'
      cancel.children = [Kramdown::Element.new(:text, 'Cancel')]
      retry_btn = Kramdown::Element.new :html_element
      retry_btn.value = 'button'
      retry_btn.attr['type'] = 'button'
      retry_btn.attr['class'] = 'quiz-retry-button'
      retry_btn.children = [Kramdown::Element.new(:text, 'Retry')]
      concede = Kramdown::Element.new :html_element
      concede.value = 'button'
      concede.attr['type'] = 'button'
      concede.attr['class'] = 'quiz-concede-button'
      concede.children = [Kramdown::Element.new(:text, 'Show Answers')]
      quiz_end_buttons.children = [cancel, submit, concede, retry_btn]
      quiz_end.children = [score, quiz_end_buttons]
      form.children << quiz_end
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
      doc = parse_markdown content
      qzn = convert_quizzes doc.root, qzn

      if qzn > 0
        js = Kramdown::Element.new :html_element
        js.value = 'script'
        js.attr['src'] = '/assets/scripts/quiz.js'
        doc.root.children << js
      end

      doc.to_html
    end
  end
end
