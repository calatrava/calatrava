module Web
  class DeparturesScreen
    def has_departure(params)
      $browser.element( :text => "#{params[:destination]} train in #{params[:etd]} min" ).exists?
    end
  end
end
