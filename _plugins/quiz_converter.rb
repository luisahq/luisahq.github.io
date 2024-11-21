require "perfect_toml"

module Jekyll
  class QuizConverter < Converter
    safe true
    priority :highest

    def matches (ext)
      ext =~ /^\.md$/i
    end

    def output_ext(ext)
      '.html'
    end

    def convert_quiz (node)
      if node.type == :codeblock && node.options[:lang] == 'quiz'
        hashmap = PerfectTOML.parse node.value
      end

      node.children.each do |child|
        convert_quiz child
      end
    end

    def convert (content)
      doc = Kramdown::Document.new content, input: 'GFM'
      convert_quiz doc.root
      doc.to_html
    end
  end
end
