require 'parslet'
require 'parslet/convenience'

class JspParser < Parslet::Parser
  def ds(start_delimiter, end_delimiter=start_delimiter, as=:value)
    str(start_delimiter) >> (str(end_delimiter).absent? >> any).repeat.as(as) >> str(end_delimiter)
  end

  rule(:s)  { match('\s').repeat(1) }
  rule(:s?) { s.maybe }

  rule(:quoted_string) { ds("'") | ds('"') }

  rule(:id) { match('[A-Za-z_]') >> match('[A-Za-z0-9_]').repeat }

  rule(:parameters) { (parameter >> s?).repeat.as(:parameters) }
  rule(:parameter)  { id.as(:name) >> s? >> str('=') >> s? >> quoted_string }

  rule(:comment) { ds("<%--", "--%>", :comment) }

  rule(:tag)           { str('<%') >> s? >> (tag_directive | tag_plain) >> s? >> str('%>') }
  rule(:tag_directive) { str('@') >> s? >> id.as(:directive) >> s >> parameters.as(:parameters) }
  rule(:tag_plain)     { (str('%>').absent? >> any).repeat.as(:content) }

  rule(:action)              { action_empty | action_with_content }
  rule(:action_empty)        { str('<') >> (id.as(:namespace) >> str(':')).maybe >> id.as(:action_type) >> (s >> parameters).maybe >> s? >> str('/>') }
  rule(:action_with_content) {
      str('<') >> id.capture(:ns).as(:namespace) >> str(':') >> id.capture(:id).as(:action_type) >> (s >> parameters).maybe >> s? >> str('>') >>
      scope { jsp_file.maybe.as(:content) } >>
      str('</') >> dynamic { |src,ctx| (str(ctx.captures[:ns]) >> str(':')).maybe >> str(ctx.captures[:id]) } >> s? >> str('>')
  }

  rule(:other) { (str('</').absent? >> str('<%').absent? >> (str('<') >> id >> str(':')).absent? >> any).repeat(1) }


  rule(:jsp_file) { (comment | tag.as(:element) | action.as(:element) | other | s).repeat }
  root :jsp_file
end
