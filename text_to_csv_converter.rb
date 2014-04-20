class Transactions

  def initialize(file)
    @original_file = File.open(file, 'r')
    @transactions = {}
    @line = ''
  end

  # RegEx
  TRANSACTION_HEADER = /Transaction\s+Id:\s+(\d+)\s+(\d+)\s+(\d+)/
  ITEM = /^ITEM\s*:\s*(\d+)\s+(\d+)/
  DATE = /^Date:\s+(\d+)-(\d+)-(\d+)/
  CASHIER = /Cashier:\s+(\d+)/
  ORIG_TRANS = /Orig.\s+Trans:\s+(\d+)/

  ATTRIBUTES = {'Date' => {:regex => DATE, :captures_order => [1, 2, 0], :join_char => '/'},
                'Transaction #' => {:regex => TRANSACTION_HEADER, :captures_order => [2], :join_char => ''},
                'Store #' => {:regex => TRANSACTION_HEADER, :captures_order => [0], :join_char => ''},
                'Reg.:' => {:regex => TRANSACTION_HEADER, :captures_order => [1], :join_char => ''},
                'Cashier:' => {:regex => CASHIER, :captures_order => [0], :join_char => ''},
                'Item' => {:regex => ITEM, :captures_order => [0, 1], :join_char => ' '},
                'Item Description' => {:regex => //, :captures_order => [], :join_char => ''}, 
                'Original Transaction:' => {:regex => ORIG_TRANS, :captures_order => [0], :join_char => ''}
               }

  def create_csv
    @new_file = File.new("#{File.basename(ARGV[0], '.txt')}.csv" , 'w')
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
    p @transactions
  end

  private

  def get_current_transaction
    new_trans_match_object = @line.match(TRANSACTION_HEADER)
    if new_trans_match_object
      @current_transaction = new_trans_match_object.captures[2]
      @transactions[@current_transaction] = {}
      @transactions[@current_transaction]['Item'] = []
      @transactions[@current_transaction]['Item Description'] = []      
    end
  end

  def assign_attribute(attribute)
    match_object = @line.match(ATTRIBUTES[attribute][:regex])
    if match_object
      value = ATTRIBUTES[attribute][:captures_order].map { |index| match_object.captures[index] }.join(ATTRIBUTES[attribute][:join_char])
      if attribute == 'Item'
        @transactions[@current_transaction][attribute] << value
      elsif attribute == 'Item Description'
        # do nothing
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


