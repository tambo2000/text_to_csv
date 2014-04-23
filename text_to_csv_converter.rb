class Transactions

  TRANSACTION_HEADER = /Transaction\s+Id:\s+(\d+)\s+(\d+)\s+(\d+)/
  ITEM = /ITEM\s*:\s*(\d+)\s+(\d+)\s+(-?\d+.\d\d)\s+(\w?)/
  DATE = /Date:\s+(\d+)-(\d+)-(\d+)/
  CASHIER = /Cashier:\s+(\d+)/
  PRICE = /Qty:\s+(\(?\d+\)?)\s+@\s+(-?\d+.\d\d)/
  ORIG_TRANS = /Orig.\s+Trans:\s+(\d+)/
  REASON = /(Item)\s+(Returned)/
  TAX = /Tax:\s+(\(?-?\d+.\d\d\)?)/
  SUBTOTAL = /Subtotal\s+(\(?-?\d+.\d\d\)?)/
  TAXABLE = /T1Taxable\s+Amount\s+(\(?-?\d+.\d\d\)?)/
  TOTAL_TAX = /Total\s+Tax\s+(\(?-?\d+.\d\d\)?)/
  TOTAL = /Total\s+(\(?-?\d+.\d\d\)?)/

  ATTRIBUTES = {'Date' => {:regex => DATE, :captures_order => [1, 2, 0], :join_char => '/'},
                'Transaction #' => {:regex => TRANSACTION_HEADER, :captures_order => [2]},
                'Store #' => {:regex => TRANSACTION_HEADER},
                'Reg.:' => {:regex => TRANSACTION_HEADER, :captures_order => [1]},
                'Cashier:' => {:regex => CASHIER},
                'Item' => {:regex => ITEM, :captures_order => [0, 1], :join_char => ' '},
                'Item Description' => {:regex => //},
                'Price' => {:regex => ITEM, :captures_order => [2]},
                'Tax Type' => {:regex => ITEM, :captures_order => [3]},
                'Quantity' => {:regex => PRICE},
                'Original Transaction:' => {:regex => ORIG_TRANS},
                'Reason' => {:regex => REASON, :captures_order => [0, 1], :join_char => ' '},
                'Tax' => {:regex => TAX},
                'Subtotal' => {:regex => SUBTOTAL},
                'Taxable' => {:regex => TAXABLE},
                'Total Tax' => {:regex => TOTAL_TAX},
                'Total' => {:regex => TOTAL}
               }

  def initialize(file)
    @original_file = File.open(file, 'r')
    @transactions = {}
    @line = ''
  end

  def create_csv
    @new_file = File.new("#{File.basename(@original_file, '.txt')}.csv" , 'w')
    @new_file.puts(ATTRIBUTES.keys.join(','))
    @transactions.each do |key, transaction| 
      transaction['Item'].each_with_index do |item, index|
        @new_file.puts( ATTRIBUTES.keys.map do |attribute| 
          transaction[attribute].class == Array ? transaction[attribute][index] : transaction[attribute]
        end.join(','))
      end
    end
    @new_file.close
  end

  def parse_text_file
    @original_file.each do |line|
      next if line.strip.empty?
      get_item_description(line)
      @line = line
      get_current_transaction
      ATTRIBUTES.keys.each { |attribute| assign_attribute(attribute) } if @current_transaction
    end

    @transactions.delete_if { |key, value| value['Item'].empty? }
  end

  private

  def get_current_transaction
    new_trans_match_object = @line.match(TRANSACTION_HEADER)
    if new_trans_match_object
      @current_transaction = new_trans_match_object.captures[2]
      @transactions[@current_transaction] = {}
      ['Item', 'Item Description', 'Price', 'Tax'].each { |attribute| @transactions[@current_transaction][attribute] = [] }
    end
  end

  def assign_attribute(attribute)
    match_object = @line.match(ATTRIBUTES[attribute][:regex])
    if match_object
      value = (ATTRIBUTES[attribute][:captures_order] || [0]).map { |index| match_object.captures[index] }.join(ATTRIBUTES[attribute][:join_char] || '')
      if  attribute == 'Item Description'
        # do nothing
      elsif @transactions[@current_transaction][attribute].class == Array
        @transactions[@current_transaction][attribute] << value
      else
        @transactions[@current_transaction][attribute] = value
      end
    end
  end

  def get_item_description(line)
    if @line.match(ITEM)
      @transactions[@current_transaction]['Item Description'] << line.strip
    end
  end

end

transactions = Transactions.new(ARGV[0])
transactions.parse_text_file
transactions.create_csv


