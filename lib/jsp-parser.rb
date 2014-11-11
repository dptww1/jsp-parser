require 'parslet'
require 'parslet/convenience'

class JspParser < Parslet::Parser
  def ds(start_delimiter, end_delimiter=start_delimiter, as=:value)
    str(start_delimiter) >> (str(end_delimiter).absent? >> any).repeat.as(as) >> str(end_delimiter)
  end

  rule(:s) { match('\\s').repeat }

  rule(:quoted_string) { ds("'") | ds('"') }

  rule(:id) { match('[A-Za-z_]') >> match('[A-Za-z0-9_]').repeat }

  rule(:parameters) { (parameter >> s).repeat }
  rule(:parameter) { id.as(:name) >> s >> str('=') >> s >> quoted_string }

  rule(:comment) { ds("<%--", "--%>", :comment) }

  rule(:tag) { str('<%') >> (tag_directive | tag_plain) >> str('%>') }

  rule(:tag_directive) { s >> str('@') >> s >> id.as(:directive) >> s >> parameters.as(:parameters) }

  rule(:tag_plain) { s >> (str('%>').absent? >> any).repeat.as(:content) }

  rule(:action) { str('<') >> id.as(:namespace) >> str(':') >> id.as(:action_type) >> s >> parameters >> str('/>') }

  rule(:other) { (str('<%').absent? >> (str('<') >> id >> str(':')).absent? >> any) }

  rule(:jsp_file) { (comment | tag.as(:element) | action.as(:element) | other >> s).repeat }
  root :jsp_file
end
