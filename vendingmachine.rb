# encoding: utf-8
# Vendingmachine implementation
# Module Vendingmachine {classes: Automat,  Product}


module Vendingmachine 

	#Class automat
	class Automat

		def initialize
			#all available products in ve
			@products = Hash.new
			#selected products by user
			@selected = Array.new
			#available cach in machine
			@cash = Hash.new(0)
			#inserted cash amount by user
			@inserted_money = 0

			@total_inserted_money = 0

			@money_codes = {'1p' => 0.01, '2p' => 0.02, '5p' => 0.05, '10p' => 0.10, '20p' => 0.20, '50p' => 0.50, '1f' => 1.00, '2f' => 2.00 }

		end

		# add product to machine
		# product has to be assigned to the code
		def add_product(product_code, product)
			@products[product_code] = product
		end

		#Display all available products in machine
		def display_available_products
			puts "\nList of all available products:"
			@products.each do |code, product|
				if product.quantity > 0
					puts code + ": " + product.name + " - " + product.price.to_s + "\u00A3"
				end
			end
		end

		# Display selected products
		def display_selected_products
			if @selected.empty?
				puts "\nYou haven't selected any product yet"		
			else
				puts "\nYour selected products:"
				@selected.each_with_index do |product, index|
					puts (index+1).to_s + ": " + product.name
				end
			end
		end

		# Display inserted user cach
		def display_inserted
			puts "\nAmount inserted: #{@inserted_money} \u00A3"
		end

		# Display all available commands
		def display_help
			puts "\nAll available commands:"
			puts '"help" - display help'
			puts '"products" - display all available products'
			puts '"selected" - display selected products'
			puts '"amount" - show cash amount inserted'
			puts '"cp" - confirm purchase and coin return' 
			puts '"cs" - machine cash status'
			puts '"1p" - insert a 1 pence'
			puts '"2p" - insert a 2 pence'
			puts '"5p" - insert a 5 pence'
			puts '"10p" - insert a 10 pence'
			puts '"20p" - insert a 20 pence'
			puts '"50p" - insert a 50 pence'
			puts '"1f" - insert a 1 pound'
			puts '"2f" - insert a 2 pounds'
			puts '"cancel" - cancel purchase'
			puts '"quit" - exit'
		end

		 # Adds cash that is available for making change.
	  def add_cash(value, quantity)
	    @cash[value] += quantity if quantity > 0
	  end

		# proccess user action
		def proccess(command)
			if !@products[command].nil?
				#mark product as seleced product
				if @products[command].quantity > 0
					if @products[command].price > @inserted_money
						puts "\nInsert more money, please"
					else
						@selected << @products[command]
						@products[command].quantity = @products[command].quantity - 1
						@inserted_money = (@inserted_money - @products[command].price).round(2)
						puts "\nYou selected product: #{@products[command].name}"
					end
				else
					puts "\nThis product is unavailable"
				end

			#handle insert monney	
			elsif !@money_codes[command].nil?
				@inserted_money += @money_codes[command]
				@total_inserted_money = @inserted_money
				display_inserted
			else

				case command
					when "selected"
						display_selected_products
					when "products"
						display_available_products
					when "amount"
						display_inserted
					when "cp"
						confirm_purchase
					when "help"
						display_help
					when "cs"
						puts "\n"+@cash.inspect
					when "cancel"
						reset
					else
						puts "\nInvalid command, for help type \"help\""
				end
			end
		end

		#Confirm purchase
		def confirm_purchase
			change = Automat.change(@inserted_money, @cash)

			if change == false
				puts "sorry, machine can't change"
			else
				puts "\n You purchased: " + @selected.map{|product| product.name}.to_s
				puts "\n cash return: " + change.join(",")
				reset
				change.each{|value| Automat.remove_cion(@cash, value)}
			end
		end

		# Make change and result cion
		def self.change(amount, machine_cash, change=[])
			
			amount = amount.round(2)

			return [0] if amount == 0 

			machine_cash.keys.sort.reverse.each do |value|

				if (amount - value) == 0
					
					return change << value

				elsif value < amount
					
					cash_reduced = machine_cash.clone

					Automat.remove_cion(cash_reduced, value)

		      result = Automat.change(amount - value, cash_reduced, change + [value])

		      return result if result	
		    end
			end

			false
		end

		#Remove one cion from machine cash
		def self.remove_cion(cash,value)
			#delete if quantity == 1
			cash.delete(value) if cash[value] == 2
			#decrease quantity if  
			cash[value] = cash[value] - 1 if cash[value] > 1
		end

		# Method run machine
		# Should be invoked after all data has been initialized
		def run
			puts 'Select your product:'
			puts 'For help type "help"'
			display_available_products

			#intercept user command
			loop do
				command = gets.chomp
				break if ['quit'].include?(command)
				proccess command
			end
		end

		#reset user order
		def reset
			@inserted_money = 0
			@total_inserted_money = 0
			@selected = Hash.new
		end

	end



	#Class Product
	#Class define product object
	class Product
		
	  attr_reader :price, :name
	  attr_accessor :quantity

	  def initialize(name, price, quantity)
	    @name, @price, @quantity = name, price, quantity
	  end

	end
end


#####################################################################################################################

automat = Vendingmachine::Automat.new

#Define list of products
cocaCola = Vendingmachine::Product.new('Coca Cola', 2, 3)
orangeJuice = Vendingmachine::Product.new('Orange juice', 1.50, 2)
coffe = Vendingmachine::Product.new('Coffe', 1.60, 1)

#adding products to vending machine

automat.add_product('A', cocaCola)
automat.add_product('B', orangeJuice)
automat.add_product('C', coffe)


#add Cash

automat.add_cash(0.01, 0)
automat.add_cash(0.02, 2)
automat.add_cash(0.05, 2)
automat.add_cash(0.10, 2)
automat.add_cash(0.20, 3)
automat.add_cash(0.50, 3)
automat.add_cash(1.00, 3)
automat.add_cash(2.00, 5)

#start vending machine
automat.run