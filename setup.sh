echo "================== Installing Dependencies ===================="
gem install bundler
bundle install
bundle exec rake db:create

echo "\\n"
echo "================== Running Migrations ===================="
bundle exec rake db:migrate

echo "\\n"
echo "================== Starting Sidekiq ===================="
bundle exec sidekiq -C config/sidekiq.yml -d -L log/sidekiq.log

echo "\\n"
echo "================== Starting Server ===================="
bundle exec unicorn -c config/unicorn.rb -D
echo "=========== Server is up and running: http://localhost:9000 ============"

echo "\\n"
echo "================== Running Tests ===================="
bundle exec rake db:migrate RAILS_ENV=test
sh all_specs.sh


echo "\\n"
echo "Done!!"