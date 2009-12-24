class Exceptions < Application
  
  # handle NotFound exceptions (404)
  def not_found
    render "errors/not_found"
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render "errors/not_acceptable"
  end

end
