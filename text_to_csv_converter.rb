class Transactions

  COLUMN_TITLES = ['Date', 'Transaction #', 'Store #', 'Reg.:', 
                   'Cashier:', 'Item', 'Item Description', 'Price', 
                   'Tax Type', 'Qty', 'Original Transaction', 
                   'Reason', 'Tax', 'Subtotal', 'Taxable', 'Tax', 'Total']

  SIMPLE_NUMERICAL_COLUMNS_TO_POPULATE = ['Cashier:', 'Orig.   Trans:']

  def initialize(file)
    @original_file = File.open(file, 'r')
    @transactions = {}
  end

  def create_csv
    @new_file = File.new("#{File.basename(ARGV[0], '.txt')}.csv" , 'w')
    @new_file.puts(COLUMN_TITLES.join(','))
    @new_file.close
  end

  def parse_text_file
    @current_transaction = nil

    @original_file.each do |line|
      next if line.strip.empty?
      get_current_transaction_and_other_values(line)
      get_simple_numerical_columns(line)
    end

    p @transactions
  end

  private

  def get_current_transaction_and_other_values(line)
    new_trans_match_object = line.match(/Transaction\s+Id:\s+(\d+)\s+(\d+)\s+(\d+)/)
    if new_trans_match_object
      @current_transaction = new_trans_match_object.captures[2]
      @transactions[@current_transaction] = {}
      @transactions[@current_transaction]['Store #'] = new_trans_match_object.captures[0]
      @transactions[@current_transaction]['Reg.:'] = new_trans_match_object.captures[1]
    end
  end

  def get_simple_numerical_columns(line)
    SIMPLE_NUMERICAL_COLUMNS_TO_POPULATE.each do |column|
      item_match_object = line.match(/#{column}\s+(\d+)/)
      @transactions[@current_transaction][column] = item_match_object.captures[0] if item_match_object
    end
  end

end

transactions = Transactions.new(ARGV[0])
transactions.parse_text_file


