# I really hate this
class NilClass#:nodoc:
  def empty?; return true; end
  def size;   return 0;    end
  def to_form; return FormArray.new([]); end
  def clop; return nil; end
  def inner_html; return nil; end
  def get_attribute(*args); return nil; end
  def grep(*args); return []; end
  def escape(*args); return nil; end
end
