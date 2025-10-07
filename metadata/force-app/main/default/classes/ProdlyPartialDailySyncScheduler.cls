global class ProdlyPartialDailySyncScheduler implements Schedulable {
   
    global void execute(SchedulableContext SC) {
        ProdlyPartialDailySync ppds = new ProdlyPartialDailySync();
    }


}

    // Run from Execute Anonymous to schedule
    
    /*******************************
    ProdlyPartialDailySyncScheduler ppdss = new ProdlyPartialDailySyncScheduler ();
        String sch = '0 0 4 * * ?';
        String jobID = System.schedule('Daily Partial Data Sync - Prodly', sch, ppdss);
        //Class runs every day at 4 AM.
    *******************************/