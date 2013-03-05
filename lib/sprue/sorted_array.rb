class Sprue::SortedArray < Array
  def <<(object)
    self[insertion_index(object),0] = object
  end
  alias_method :unshift, :<<
  alias_method :push, :<<

  def +(array)
    (self + array).sort
  end

  def concat(array)
    array.each do |object|
      self << object
    end
  end

protected
  def insertion_index(object, index_start = 0, index_end = self.length - 1)
    if (index_start > index_end)
      return index_start
    end

    index_middle = (index_start + index_end) / 2
    
    if (self[index_middle] == object)
      index_middle
    elsif (object > self[index_middle])
      insertion_index(object, index_middle + 1, index_end)
    else
      insertion_index(object, index_start, index_middle - 1)
    end
  end
end
