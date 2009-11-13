unless Array.method_defined? :sample then
  if Array.method_defined? :choice then
    class Array; alias sample choice; end
  else
    class Array; def sample; at(Kernel.rand(size)); end; end
  end
end

