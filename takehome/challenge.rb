require 'json'
# using the json package so that we can grab the data from the users json and companies json and store them into an array

# read the companies json and the users json
companies = File.read('companies.json')
users = File.read('users.json')

#before we can use the data we have to parse it, the following two lines of code parses the data and creates arrays in which the user and companies data is stored
companies_list = JSON.parse(companies)
users_list =  JSON.parse(users)

#I create a file for writing, if the file does not exist, it is created due to the second parameter "w"
file = File.open('output.txt', 'w')

#I want to skip the first line so I create an empty line
file.write("\n")

# I create a hash map to keep track of the top up totals for each company
# I know I can keep track of the total top ups for each company with a temp variable inside the for each loop but I just though it would be cleaner
# and simpler if I just made a hash map containing the value of each companies total top up
top_up_totals = Hash.new

#I also create a hash map to keep track of which companies have employees, ie company 6 has no employees therefore it should not be included in the output file
no_employees = Hash.new

#Initialize each total top up to 0
companies_list.each do |company|
    top_up_totals[company['id']] = 0
end

#Initialize the hash map which tracks which companies have employees or not
companies_list.each do |company|
    no_employees[company['id']] = false
end

#I want to see if a company has at least 1 active employee so that I can write that information to the output txt file
users_list.each do |person|
    if person['active_status'] == true && no_employees.key?(person['company_id'])
        no_employees[person['company_id']] = true
    end
end

#I want to sort users array (which is an array of hashmaps), by the last name. The following code does so by using the sory_by methog
#I specifiy that I want to sort the users list array by the last_name value
sorted_users = users_list.sort_by {|users_list| users_list['last_name']}



# I start by looping through each company
companies_list.each do |company|
    #Check to see if the company has any employees, if they do not have any the you do not need to wrte that companies information to the output file
    if no_employees[company['id']] == true
        file.write('    ' + "Company Id: " + company['id'].to_s + "\n")
        file.write('    ' + "Company Name: " + company['name'] + "\n")
        #If a companies email status is false, I know automatically that no emails will be sent out so the user emailed field will always be blank
        if company['email_status'] == false
            file.write('    ' + "Users Emailed: \n")
            file.write('    ' + "Users Not Emailed: \n")
            #I loop through each user to make sure they are an active employee and that they belong to the current company I am looping through
            sorted_users.each do |sorted_user|
                if (sorted_user['company_id'] == company['id']) && sorted_user['active_status'] == true
                    file.write('        ' + sorted_user['last_name'] + ", " + sorted_user['first_name'] + ", " + sorted_user['email'] + "\n" )
                    file.write('          ' + "Previous Token Balance, " + sorted_user['tokens'].to_s + "\n" )
                    file.write('          ' + "New Token Balance " + (sorted_user['tokens'] + company['top_up']).to_s + "\n" )
                    top_up_totals[company['id']] += company['top_up']
                    #I have to make sure that everytime I top up an employee I add it to the companies total top ups
                end
            end
            file.write('        ' + 'Total amount of top ups for ' + company['name'] + ": " + top_up_totals[company['id']].to_s + "\n\n")
            #Add the total top ups to the end of all the info written for a company insde the txt file
        else
            #If a companies email status is true, I know that some employees are capable of getting an email if and only if their email status is "active"
            file.write('    ' + "Users Emailed: \n")
            sorted_users.each do |sorted_user|
                if ((sorted_user['company_id'] == company['id']) && (sorted_user['active_status'] == true) && (sorted_user['email_status'] == true))
                    file.write('        ' + sorted_user['last_name'] + ", " + sorted_user['first_name'] + ", " + sorted_user['email'] + "\n" )
                    file.write('          ' + "Previous Token Balance, " + sorted_user['tokens'].to_s + "\n" )
                    file.write('          ' + "New Token Balance " + (sorted_user['tokens'] + company['top_up']).to_s + "\n" )
                    top_up_totals[company['id']] += company['top_up']
                    # Same thing as before, I have to make sure that everytime I top up an employee I add it to the companies total top ups
                end
            end
            #If a companies email status is true and their employees is active but email status isnt, then I still need to top up but not send an email 
            file.write('    ' + "Users Not Emailed: \n")
            sorted_users.each do |sorted_user|
                if ((sorted_user['company_id'] == company['id']) && (sorted_user['active_status'] == true) && (sorted_user['email_status'] == false))
                    file.write('        ' + sorted_user['last_name'] + ", " + sorted_user['first_name'] + ", " + sorted_user['email'] + "\n" )
                    file.write('          ' + "Previous Token Balance, " + sorted_user['tokens'].to_s + "\n" )
                    file.write('          ' + "New Token Balance " + (sorted_user['tokens'] + company['top_up']).to_s + "\n" )
                    top_up_totals[company['id']] += company['top_up']
                end
            end
            file.write('        ' + 'Total amount of top ups for ' + company['name'] + ": " + top_up_totals[company['id']].to_s + "\n\n")
            #Add the total top ups to the end of all the info written for a company insde the txt file
        end
    end
end
