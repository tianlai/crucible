# date based version to force tests to reload on startup
LOAD_VERSION=20160222

Test.any_of({:load_version.exists => false},{:load_version.lt => LOAD_VERSION}).delete

stored_tests = Test.all.to_a.map {|t| t.id}
executor = Crucible::Tests::Executor.new(nil)

Crucible::Tests::Executor.list_all.each do |key,value|
  test_id = value['id'].parameterize('_')
  unless stored_tests.include?(test_id)
    test = Test.new
    test.id = test_id
    test.name = key.to_s
    test.title = value["title"]
    test.author = value["author"]
    test.description = value["description"]
    test.tags = value['tags']
    test.category = value['category']
    test.details = value['details'] unless value['details'].blank?

    crucibleTest = executor.find_test(value['title'])
    if value["resource_class"]
      test.resource_class = value["resource_class"].to_s
      crucibleTest.resource_class = value["resource_class"]
    end
    test.multiserver = value["multiserver"]
    test.load_version = LOAD_VERSION

    metadata = crucibleTest.collect_metadata

    test.methods = metadata.values.first.map do |method|
      method.except('data','code', 'status', 'message')
    end

    test.save()

  end

end
