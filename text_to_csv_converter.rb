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

  DATE_STR = 'Date'
  TRANSACTION_STR = 'Transaction #'
  STORE_STR = 'Store #'
  REG_STR = 'Reg.:'
  CASHIER_STR = 'Cashier:'
  ITEM_STR = 'Item'
  ITEM_DESCRIPTION_STR = 'Item Description'
  PRICE_STR = 'Price'
  TAX_TYPE_STR = 'Tax Type'
  QUANTITY_STR = 'Quantity'
  ORIG_TRANS_STR = 'Original Transaction'
  REASON_STR = 'Reason'
  TAX_STR = 'Tax'
  SUBTOTAL_STR = 'Subtotal'
  TAXABLE_STR = 'Taxable'
  TOTAL_TAX_STR = 'Total Tax'
  TOTAL_STR = 'Total'

  ATTRIBUTES = {DATE_STR => {:regex => DATE, :captures_order => [1, 2, 0], :join_char => '/'},
                TRANSACTION_STR => {:regex => TRANSACTION_HEADER, :captures_order => [2]},
                STORE_STR => {:regex => TRANSACTION_HEADER},
                REG_STR => {:regex => TRANSACTION_HEADER, :captures_order => [1]},
                CASHIER_STR => {:regex => CASHIER},
                ITEM_STR => {:regex => ITEM, :captures_order => [0, 1], :join_char => ' '},
                ITEM_DESCRIPTION_STR => {:regex => //},
                PRICE_STR => {:regex => ITEM, :captures_order => [2]},
                TAX_TYPE_STR => {:regex => ITEM, :captures_order => [3]},
                QUANTITY_STR => {:regex => PRICE},
                ORIG_TRANS_STR => {:regex => ORIG_TRANS},
                REASON_STR => {:regex => REASON, :captures_order => [0, 1], :join_char => ' '},
                TAX_STR => {:regex => TAX},
                SUBTOTAL_STR => {:regex => SUBTOTAL},
                TAXABLE_STR => {:regex => TAXABLE},
                TOTAL_TAX_STR => {:regex => TOTAL_TAX},
                TOTAL_STR => {:regex => TOTAL}
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
      transaction[ITEM_STR].each_with_index do |item, index|
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

    @transactions.delete_if { |key, value| value[ITEM_STR].empty? }
  end

  private

  def get_current_transaction
    new_trans_match_object = @line.match(TRANSACTION_HEADER)
    if new_trans_match_object
      @current_transaction = new_trans_match_object.captures[2]
      @transactions[@current_transaction] = {}
      [ITEM_STR, ITEM_DESCRIPTION_STR, PRICE_STR, TAX_STR].each { |attribute| @transactions[@current_transaction][attribute] = [] }
    end
  end

  def assign_attribute(attribute)
    match_object = @line.match(ATTRIBUTES[attribute][:regex])
    if match_object
      value = (ATTRIBUTES[attribute][:captures_order] || [0]).map { |index| match_object.captures[index] }.join(ATTRIBUTES[attribute][:join_char] || '')
      if  attribute == ITEM_DESCRIPTION_STR
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
      @transactions[@current_transaction][ITEM_DESCRIPTION_STR] << line.strip
    end
  end

end

transactions = Transactions.new(ARGV[0])
transactions.parse_text_file
transactions.create_csv


