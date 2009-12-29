# Copyright (c) 2009 Kevin Menard <nirvdrum@gmail.com>
# This code was heavily influenced by Edgar Gonzalez's work on another W3C
# SOAP parsing project.  His software is licensed as follows:

# Portions copyright (c) 2006 Edgar Gonzalez <edgar@lacaraoscura.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'nokogiri'

class HtmlValidatorParser

  def initialize
    clear
  end

  def parse(response)
    xml = Nokogiri::XML(response)
    xml.remove_namespaces!

    uri = xml.at_xpath("//Body/markupvalidationresponse/uri").content
    init_uri(uri)

    xml.xpath("//Envelope/Body/markupvalidationresponse/errors/errorlist/error").each do |error|
      error_hash = {}
      error.children.each do |error_component|
        next if error_component.name == 'text'

        error_hash[translate_name(error_component.name)] = error_component.content.strip
      end

      # Store errors for URI under :errors key.
      @results[uri][:errors] << error_hash

      # Store errors for URI by line number.
      error_line = error_hash[:line].to_i
      init_error_for_line(uri, error_line)
      @results[uri][error_line][:errors] << error_hash
    end

    xml.xpath("//Envelope/Body/markupvalidationresponse/warnings/warninglist/warning").each do |warning|
      warning_hash = {}
      warning.children.each do |warning_component|
        next if warning_component.name == 'text'

        warning_hash[translate_name(warning_component.name)] = warning_component.content.strip
      end

      # Store warnings for URI under :warnings key.
      @results[uri][:warnings] << warning_hash

      # Store warnings for URI by line number.
      warning_line = warning_hash[:line].to_i
      init_warning_for_line(uri, warning_line)
      @results[uri][warning_line][:warnings] << warning_hash
    end
  end

  def clear
    @results = {}
  end

  def keys
    @results.keys
  end

  def [](uri)
    @results[uri]
  end

  private

  def init_uri(uri)
    @results[uri] ||= {}
    @results[uri][:errors] ||= []
    @results[uri][:warnings] ||= []
  end

  def init_error_for_line(uri, line)
    @results[uri][line] ||= {}
    @results[uri][line][:errors] ||= []
  end

  def init_warning_for_line(uri, line)
    @results[uri][line] ||= {}
    @results[uri][line][:warnings] ||= []
  end

  def translate_name(name)
    case name
      when 'col' then :column
      else name.to_sym
    end
  end

end