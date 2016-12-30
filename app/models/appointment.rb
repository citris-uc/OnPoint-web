class Appointment < ActiveRecord::Base
end

# /*
#  * @param date is in ISO format
#  */
# createAppointmentCards: function(date, object_type) {
#   var that = this;
#   var now  = (new Date()).toISOString();
#   var date_key = date.substring(0,10);
#
#   var d = new Date(date); //date in JS Date format
#   var toDate = new Date(date);
#   toDate.setDate(d.getDate()+CARD.TIMESPAN.DAYS_BEFORE_APPT);
#   var ref = Appointment.getAppointmentsFromToRef(d, toDate);
#   //var ref = Appointment.ref();
#   ref.once("value", function(snap) {
#     snap.forEach(function(childSnap) { //for each date
#       childSnap.forEach(function(apptSnap) {
#         var appt = apptSnap.val();
#         var show = new Date(date);
#
#         //TODO: When should the reminder cards show up?
#         show.setHours(CARD.REMINDER_TIME.HOUR);
#         show.setMinutes(CARD.REMINDER_TIME.MINUTE);
#
#         var card = {
#           type: CARD.TYPE.REMINDER,
#           created_at: now,
#           updated_at: now,
#           shown_at: show.toISOString(),
#           completed_at: null,
#           archived_at: null,
#           num_comments: 0,
#           object_type: object_type,
#           object_id: apptSnap.key()
#         }
#         that.create(date_key, card);
#       })
#     })
#   });
#
# },
