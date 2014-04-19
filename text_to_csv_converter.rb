class Transactions

  def initialize(file)
    @original_file = File.open(file, 'r')
    @transactions = {}
  end

  # RegEx
  TRANSACTION_HEADER = /Transaction\s+Id:\s+(\d+)\s+(\d+)\s+(\d+)/
  ITEM = /ITEM:\s+(\d+)\s+(\d+)/
  DATE = /^Date:\s+(\d+)-(\d+)-(\d+)/
  CASHIER = /Cashier:\s+(\d+)/
  ORIG_TRANS = /Orig.\s+Trans:\s+(\d+)/

  ATTRIBUTES = {'Date' => {:regex => DATE, :captures_order => [1, 2, 0], :join_char => '/'},
                'Transaction #' => {:regex => TRANSACTION_HEADER, :captures_order => [2], :join_char => ''},
                'Store #' => {:regex => TRANSACTION_HEADER, :captures_order => [0], :join_char => ''},
                'Reg.:' => {:regex => TRANSACTION_HEADER, :captures_order => [1], :join_char => ''},
                'Cashier:' => {:regex => CASHIER, :captures_order => [0], :join_char => ''},
                'Item' => {:regex => ITEM, :captures_order => [0, 1], :join_char => ' '},
                'Original Transaction:' => {:regex => ORIG_TRANS, :captures_order => [0], :join_char => ''}
               }

  def create_csv
    
    @new_file = File.new("#{File.basename(ARGV[0], '.txt')}.csv" , 'w')
    @new_file.puts(COLUMN_TITLES.join(','))
    @new_file.close
  end

  def parse_text_file
    @current_transaction = nil

    @original_file.each do |line|
      next if line.strip.empty?
      @line = line
      get_current_transaction

      ATTRIBUTES.keys.each do |attribute|
        assign_hash(attribute)
      end
    end

    @transactions.delete_if { |key, value| value['Item'].nil? }
    p @transactions
  end

  private

  def get_current_transaction
    new_trans_match_object = @line.match(TRANSACTION_HEADER)
    if new_trans_match_object
      @current_transaction = new_trans_match_object.captures[2]
      @transactions[@current_transaction] = {}
    end
  end

  def assign_hash(attribute)
    match_object = @line.match(ATTRIBUTES[attribute][:regex])
    @transactions[@current_transaction][attribute] = ATTRIBUTES[attribute][:captures_order].map { |index| match_object.captures[index] }.join(ATTRIBUTES[attribute][:join_char]) if match_object
  end

end

transactions = Transactions.new(ARGV[0])
transactions.parse_text_file


