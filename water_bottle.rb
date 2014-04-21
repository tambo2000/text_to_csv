# is_substring, returns whether one string is a substring of another string

def is_substring(string, substring)
  return true if substring == ''
  0.upto(string.length - 1) do |beginning|
    (beginning + 1).upto(string.length) do |end_of_string|
      return true if string[beginning..end_of_string] == substring
    end
  end
  false
end

def rotation(string1, string2)
  return false if string1.length != string2.length
  doubled_string = string1 + string1
  is_substring(doubled_string, string2)
end

str1 = 'waterbottle'
str2 = 'aterbottlew'
str3 = 'aterbottle'
str4 = ''

p rotation(str1, str2)
p rotation(str1, str3)
p rotation(' ', ' ')
p rotation('', '')
p rotation(str1, '')
p rotation('', str1)


