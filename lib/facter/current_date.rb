# current_date.rb

Facter.add("current_date") do
  setcode do
      Facter::Util::Resolution.exec('/bin/date +%D')
        end
end
