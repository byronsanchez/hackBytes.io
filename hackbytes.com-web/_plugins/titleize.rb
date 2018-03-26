module Jekyll
  module HandleFilter

    def titleize(content)
      content.split(" ").map(&:capitalize).join(" ")
    end

  end
end

Liquid::Template.register_filter(Jekyll::HandleFilter)
