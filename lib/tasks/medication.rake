
# These tasks run in our Heroku Scheduler
# See: https://devcenter.heroku.com/articles/scheduler
namespace :medication do
  task :populate_images => [:environment] do
    @firebase = Firebase::Client.new(ENV["FIREBASE_URL"], ENV["FIREBASE_DATABASE_SECRET"])

    patients = Patient.all
    patients.each do |uid, v|
      medications = Medication.all(uid)
      next if medications.blank?

      medications.each do |med_id,v|
        med = Medication.get(uid, med_id)
        next if med.blank? || med["image"].present?

        if med["nickname"].present?
          query_name = med["nickname"].downcase.strip
          rxcuis     = Drug.find_rxcuis_by_name(query_name)
          if rxcuis.present?
            d = Drug.new(rxcuis[0])
            d.scd = d.find_scd_matches()
            drugs = d.scd
            Drug.find_image_for_drugs(drugs, med["nickname"])

            med["image"] = drugs[0][:image]
            puts "med = #{med["image"]}"
            Medication.update(uid, med_id, med)
          end

        end
      end
    end
  end
end
