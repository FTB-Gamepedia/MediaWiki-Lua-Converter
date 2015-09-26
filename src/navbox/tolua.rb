require 'mediawiki-butt'

butt = MediaWiki::Butt.new("http://ftb.gamepedia.com/api.php")
moduletext = butt.get_text("Module:Mods/list")

puts "Please input your file containing your navbox"
file_name = gets.chomp
file = File.read(file_name)

# Remove Translate crap because it makes everything way harder.
file = file.gsub(/<translate>/, "")
file = file.gsub(/<\/translate>/, "")
file = file.gsub(/<!--T:\d{1,}-->\n/, "")
file = file.gsub(/<noinclude>/, "")
file = file.gsub(/<\/noinclude>/, "")

# This is super messy, but works. Consider refactoring.
title = file.match(/\|title\=\{\{[Ll]\|([^\}\}]*)/).to_s.gsub(/\|title=|{\{[Ll]\|/, "")

# TODO: Get rid of shitty whitespace before and after abbreviation.
abbreviationline = moduletext.match(/\s.*\s=\s\{\'#{title}/).to_s
abbreviation = abbreviationline.match(/\s(.*)\s=/)[1]
puts abbreviation

titles = file.scan(/\{\{[Nn]avbox subgroup\n.*\|title\=([^\n]*)\n/)

text = "--<languages />\n--<pre>\nlocal p = {}\np.navbox = function(navbox, highlightline, group, list, line, ni, l)\n\n"
text = text + "local #{title.downcase} = --[[<translate>]] l{\"#{title}\"} --[[</translate>]]\n\n"
titles.each do |tit|
  #lmao
  text = text + "local #{tit[0].downcase} = [=[<translate>#{tit[0]}</translate>]=]\n\n"
end
puts text
