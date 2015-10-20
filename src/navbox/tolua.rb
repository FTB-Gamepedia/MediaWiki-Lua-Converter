require 'mediawiki-butt'

$butt = MediaWiki::Butt.new("http://ftb.gamepedia.com/api.php")
$moduletext = $butt.get_text("Module:Mods/list")

def convert(template_text)
  # Remove Translate crap because it makes everything way harder.
  template_text = template_text.gsub(/<translate>/, "")
  template_text = template_text.gsub(/<\/translate>/, "")
  template_text = template_text.gsub(/<!--T:\d{1,}-->\n/, "")
  template_text = template_text.gsub(/<noinclude>/, "")
  template_text = template_text.gsub(/<\/noinclude>/, "")
  puts template_text

  # This is super messy, but works. Consider refactoring.
  # FIXME: character class has duplicated range
  title = template_text.match(/\|title\=\{\{[Ll]\|([^\}\}]*)/).to_s.gsub(/\|title=|{\{[Ll]\|/, "")

  abbreviationline = $moduletext.match(/\s.*\s=\s\{\'#{title}/).to_s
  abbreviation = abbreviationline.match(/\s(.*)\s=/)[1]
  abbreviation = abbreviation.gsub(/\s/, '')
  puts abbreviation

  titles = template_text.scan(/\{\{[Nn]avbox subgroup\n.*\|title\=([^\n]*)\n/)

  # FIXME: This does not get the subgroup group names.
  list_titles = template_text.scan(/\{\{[Nn]avbox subgroup\n.*\|group\d\=([^\n]*)\n/)

  text = "--<languages />\n--<pre>\nlocal p = {}\np.navbox = function(navbox, highlightline, group, list, line, ni, l)\n\n"
  text = text + "local #{title.downcase} = --[[<translate>]] l{\"#{title}\"} --[[</translate>]]\n\n"
  titles.each do |tit|
    tit = tit[0]
    text = text + "local #{tit.downcase} = [=[<translate>#{tit}</translate>]=]\n\n"
  end

  list_titles.each do |tit|
    tit = tit[0]
    text = text + "local #{tit.downcase} = [=[<translate>#{tit}</translate>]=]\n\n"
  end

  text = text + "return navbox{title = #{title.downcase}, mod = \"#{abbreviation}\",\n"
  titles.each do |tit|
    tit = tit[0].downcase
    text = text + "\tgroup{ name = \"#{tit}\", title = #{tit},\n"
    list_titles.each do |ltit|
      ltit = ltit[0].downcase
      text = text + "\t\tlist{ title = #{ltit},\n"
    end
  end
  puts text
end

valid = false
while valid == false
  print 'Please input your template\'s name: '
  template_name = gets.chomp
  # TODO: Allow for the user to put in Template:Navbox OpenBlocks,
  #   Navbox OpenBlocks, or just OpenBlocks
  template_name = "Template:Navbox #{template_name}"

  $template_text = $butt.get_text(template_name)

  if $template_text.nil?
    puts 'Sorry, that is not a valid page. Please make sure you type the' \
         ' right page, because it does spam the wiki with a fat GET'
    valid = false
  else
    valid = true
    break
  end
end

convert($template_text)
