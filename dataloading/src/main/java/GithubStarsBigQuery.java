import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

public class GithubStarsBigQuery {
    static long startFirstWeek = 1413676800;
    static long weekDuration = 1414281600 - startFirstWeek;

    // 2019-01-02 11:15:41 UTC
    static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss zzz");

    public static void main(String[] args) throws IOException {
        File csvDataDir = new File("dataloading/data/stardata_bigquery");
        System.out.println("Exists: " + csvDataDir.exists());
        File[] csvFiles = csvDataDir.listFiles();
        HashMap<Integer, Integer> weekCounter = new HashMap<>();
        for (File csvFile : csvFiles) {
            List<String> lines = FileUtils.readLines(csvFile);
            for (String line : lines) {
                String dateStr = line.split(",")[2];
                try {
                    int weekNum = getWeekNumForDate(dateStr);
                    weekCounter.put(weekNum, weekCounter.getOrDefault(weekNum, 0) + 1);
                } catch (ParseException e) {
                    System.err.println("Error parsing date: " + dateStr);
                }
            }
        }

        File outFile = new File("starsbyweek-frombigquery.tsv");
        FileWriter fileWriter = new FileWriter(outFile);
        List<Integer> weeks = weekCounter.keySet().stream().sorted().collect(Collectors.toList());
        for (Integer weekNum : weeks) {
            System.out.println("Week num " + weekNum + ": " + weekCounter.get(weekNum));
            fileWriter.write(weekNum + "\t" + weekCounter.get(weekNum) + "\n");
        }
        fileWriter.close();

    }

    private static int getWeekNumForDate(String date) throws ParseException {
        Date dateTime = sdf.parse(date);
        long time = dateTime.getTime() / 1000;
//        System.out.println("Time: " + time);
        time -= startFirstWeek;
        return (int) Math.floor(time / weekDuration);
    }

}
