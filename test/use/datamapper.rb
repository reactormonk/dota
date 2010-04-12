BareTest.new_component :datamapper do
  require 'dm-core'

  DataMapper.auto_migrate!

  setup do
    DataMapper.repository do |r|
      transaction = DataMapper::Transaction.new(r)
      transaction.begin
      r.adapter.push_transaction(transaction)
    end
  end

  teardown do
    DataMapper.repository do |r|
      adapter = r.adapter
      while adapter.current_transaction
        adapter.pop_transaction.rollback
      end
    end
  end
end
