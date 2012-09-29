When /^I create an app named "([^"]+)"$/, :create_app
When /^I start apache$/, :start_apache, :on => lambda { current_app }

