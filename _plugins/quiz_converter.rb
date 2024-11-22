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

        if !question.has_key? 'answers'
          raise 'Multiple choice question must have a "answers" key.'
        end

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

    def normalize_quiz (quiz)
      if !quiz.has_key? 'questions'
        raise 'Quiz does not have any questions.'
      end

      if !quiz['questions'].instance_of? Array
        raise 'Questions must be an array.'
      end

      quiz['questions'].each do |question| normalize_question question end
    end

    def convert_quizzes (node)
      if node.type == :codeblock && node.options[:lang] == 'quiz'
        quiz = PerfectTOML.parse node.value
        normalize_quiz quiz
        p quiz
      end

      node.children.each do |child| convert_quizzes child end
    end

    def convert (content)
      doc = Kramdown::Document.new content, input: 'GFM'
      convert_quizzes doc.root
      doc.to_html
    end
  end
end
