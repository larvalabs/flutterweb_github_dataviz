import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.joda.time.DateTime;
import org.joda.time.format.ISODateTimeFormat;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

public class GithubStars {
    static long startFirstWeek = 1413676800;
    static long weekDuration = 1414281600 - startFirstWeek;

    public static void main(String[] args) throws IOException, JSONException {
//        File contributorFile = new File("/Users/matt/code/flutter/github_dataviz/web/github_data/contributors.json");
        int week = getWeekNumForDate("2015-03-27T19:19:32Z");
        System.out.println("Test week: " + week);
        HashMap<Integer, Integer> weekCounter = new HashMap<>();

        OkHttpClient httpClient = new OkHttpClient();
        int pageNum = 1;
        boolean done = false;
        while (!done) {
            Request request = new Request.Builder()
                    .url("https://api.github.com/repos/flutter/flutter/stargazers?client_id=c0c1a8edcdb71645503a&client_secret=9280a62d2e26425c038ddfe99a0f5db0a730848d&per_page=100&page=" + pageNum)
                    .addHeader("Accept", "application/vnd.github.v3.star+json")
                    .build();
            try (Response response = httpClient.newCall(request).execute()) {
                String jsonStr = response.body().string();
//                System.out.println(jsonStr);
                JSONArray starJsonArray = new JSONArray(jsonStr);
                for (int i = 0; i < starJsonArray.length(); i++) {
                    JSONObject obj = starJsonArray.getJSONObject(i);
                    String dateStr = obj.getString("starred_at");
                    int weekNum = getWeekNumForDate(dateStr);
                    weekCounter.put(weekNum, weekCounter.getOrDefault(weekNum, 0) + 1);
                }
                System.out.println("Page "+pageNum+" length: " + starJsonArray.length());
                if (starJsonArray.length() < 100 || pageNum > 398) {
                    done = true;
                }
                pageNum++;
            } catch (Exception e) {
                e.printStackTrace();
                break;
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

    private static int getWeekNumForDate(String date) {
        DateTime dateTime = ISODateTimeFormat.dateTimeNoMillis().parseDateTime(date);
        long time = dateTime.toDate().getTime() / 1000;
//        System.out.println("Time: " + time);
        time -= startFirstWeek;
        return (int) Math.floor(time / weekDuration);
    }
}
