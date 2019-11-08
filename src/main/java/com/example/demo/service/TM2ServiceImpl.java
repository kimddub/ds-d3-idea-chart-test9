package com.example.demo.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class TM2ServiceImpl implements TM2Service{
	@Value("${custom.tm2Url}")
	String tm2Url;

	public JSONArray getKeywordMonthlyData(String keyword) {
		
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		
		Date today = new Date();
		
		Calendar cal = Calendar.getInstance();
		
		cal.setTime(today);
		cal.set(Calendar.DATE, 1);
		cal.add(Calendar.YEAR, -1);
		cal.add(Calendar.MONTH, 1);
		
        Date yearAgo = cal.getTime();
	
		// tm2 URL 생성
		String tm2Url = setUrlOfAssociationTransitionBySentiment(keyword, "I", formatter.format(yearAgo), formatter.format(today));

		// tm2 API 조회
		String dataStr = readURL(tm2Url);

		if (dataStr == null) {
			return null;
		}
		
		// 분석 결과 데이터 형태로 만듬 
		JSONArray data = getAnalysisData(keyword, dataStr);
		
		return data;
	}
	
	private String setUrlOfAssociationTransitionBySentiment(String keyword, String sns, String startDate, String endDate) {
		
		String source = "";
		
		if (sns.equals("B")) {
			source = "blog";
			
		} else if (sns.equals("I")) {
			source = "insta";
			
		} else if (sns.equals("N")) {
			source = "news";
			
		} else if (sns.equals("T")) {
			source = "twitter";
			
		} 
		
		
		// period >> 0 : 일별, 1 : 주별,2 : 월별, 3 : 분기,4 : 반기, 5 : 연간
		 
		String urlKeyword = "&keyword=" + URLEncoder.encode(keyword);
		String urlBasicTm2Condition = "lang=ko&command=GetAssociationTransitionBySentiment&topN=0&cutOffFrequencyMin=0&cutOffFrequencyMax=0&start_weekday=SUNDAY&categorySetName=SM";
		String urlSource = "&source=" + source; // insta, blog, twitter, news ...
		String urlStartDate = "&startDate=" + startDate;
		String urlEndDate = "&endDate=" + endDate;
		String urlPeriod = "&period=" + "2";
		
		String keywordUrl = tm2Url + urlBasicTm2Condition
									+ urlKeyword
									+ urlSource
									+ urlStartDate 
									+ urlEndDate
									+ urlPeriod;
		
		return keywordUrl;
	}
	
	private JSONArray getAnalysisData(String keyword, String dataStr) {
		
		JSONArray dataList = new JSONArray();
		
		try{
			
			// Json parser를 만들어 만들어진 문자열 데이터를 객체화 합니다. 
			JSONParser parser = new JSONParser(); 
			JSONObject obj = (JSONObject) parser.parse(dataStr); 
			
			// Top레벨 단계인 rows 키를 가지고 데이터를 파싱합니다. 
			//JSONObject parse_rows = (JSONObject) obj.get("rows"); 
			
			// List인 rows의 요소를 받아오기 : 뒤에 [ 로 시작하므로 jsonarray이다 
			JSONArray rows = (JSONArray) obj.get("rows"); 
			
			JSONObject row; 
			JSONObject keywordSentiment;
			String regDate; 
			Long positive;
			Long negative;
			Long neutral;
			
			// parse_item은 배열형태이기 때문에 하나씩 데이터를 하나씩 가져올때 사용합니다. 
			// 필요한 데이터만 가져오려고합니다. 
			for(int i = 0 ; i < rows.size(); i++) { 
				row = (JSONObject) rows.get(i); 
				
				regDate = (String)row.get("date");
				
				keywordSentiment = (JSONObject) row.get(keyword); 
				positive = (Long)keywordSentiment.get("positive");
				negative = (Long)keywordSentiment.get("negative");
				neutral = (Long)keywordSentiment.get("neutral");
				
				Long empty = new Long(0);
				
				if (!positive.equals(empty) || !negative.equals(empty) || !neutral.equals(empty)) {
					JSONObject data = new JSONObject();
					
					Long denominator = positive + negative + neutral;
					Double sentimentScore = denominator == 0? (double)50 : (double)((1*positive + 0*neutral + (-1)*negative)*100/(denominator) + 100)/2;
					
					data.put("date", regDate);
					data.put("score", sentimentScore);
					
					dataList.add(data);
				}
			} 
			
		}catch(Exception e){ 
			System.out.println(e.getMessage()); 
		}
		
		return dataList;
	}
	

	public JSONObject getAssocSentimnetData(String keyword, String analysisDatestr) {
		
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date today = new Date();
		
		String startDate = analysisDatestr;
		String endDate = formatter.format(today);
        
		try {
			Date analysisDate = formatter.parse(startDate);
			
	        Calendar cal = Calendar.getInstance();
	        
			cal.setTime(analysisDate);
			
			// 같은 달 아니면 그 달의 말일까지
			if (analysisDate.getMonth() != today.getMonth() || analysisDate.getYear() != today.getYear()) {
				endDate = analysisDatestr.substring(0,6) + cal.getActualMaximum(Calendar.DAY_OF_MONTH);
			}
			
		} catch (Exception e) {
			System.out.println("날짜 형식 오류");
		}
		
//		System.out.println("기간: " + startDate + "~" + endDate);
		
		//// tm2 감성 ////
		String sentimentUrl = setUrlOfAssociationBySentiment(keyword, "I", startDate, endDate); // URL 생성
		
		String sentimentStr = readURL(sentimentUrl); // API 조회
		
		if (sentimentStr == null) {
			return null;
		}
		
		Map<String,Object> sentimentRatio = getSenetimentRatio(keyword, sentimentStr); // 분석 결과 데이터 형태로 만듬 
	
		//// tm2 연관어 ////
		String assocUrl = setUrlOfTopAssocSentimentByPeriod(keyword, "I", startDate, endDate); // URL 생성
		
		String assocStr = readURL(assocUrl); // API 조회
		if (assocStr == null) {
			return null;
		}
		
		JSONObject senetimentData = getSenetimentData(keyword, assocStr, sentimentRatio); // 분석 결과 데이터 형태로 만듬 
		
		return senetimentData;
	
	}
	
	private String setUrlOfAssociationBySentiment(String keyword, String sns, String startDate, String endDate) {
		String source = "";
		
		if (sns.equals("B")) {
			source = "blog";
		} else if (sns.equals("I")) {
			source = "insta";
		} else if (sns.equals("N")) {
			source = "news";
		} else if (sns.equals("T")) {
			source = "twitter";
		} 
		
		String urlBasicTm2Condition = "lang=ko&source=insta&topN=10&cutOffFrequencyMin=0&cutOffFrequencyMax=0&categorySetName=SM&command=GetAssociationBySentiment";
		String urlKeyword = "&keyword=" + URLEncoder.encode(keyword);
		String urlSource = "&source=" + source; // insta, blog, twitter, news ...
		String urlStartDate = "&startDate=" + startDate;
		String urlEndDate = "&endDate=" + endDate;
		
		String keywordUrl = tm2Url + urlBasicTm2Condition
									+ urlKeyword
									+ urlSource
									+ urlStartDate 
									+ urlEndDate;
				
		return keywordUrl;
	}
	
	private Map<String,Object> getSenetimentRatio(String keyword, String dataStr) {
		
		Map<String,Object> result = new HashMap<>();
		
		try{
			
			// Json parser를 만들어 만들어진 문자열 데이터를 객체화 합니다. 
			JSONParser parser = new JSONParser(); 
			JSONObject obj = (JSONObject) parser.parse(dataStr); 
			
			Object positive = (Object) obj.get("positive"); 
			Object negative = (Object) obj.get("negative"); 
			
			result.put("positive", positive);
			result.put("negative", negative);
			
		}catch(Exception e){ 
			System.out.println(e.getMessage()); 
		}
		
		return result;
	}
	
	private String setUrlOfTopAssocSentimentByPeriod(String keyword, String sns, String startDate, String endDate) {
		
		String source = "";
		
		if (sns.equals("B")) {
			source = "blog";
		} else if (sns.equals("I")) {
			source = "insta";
		} else if (sns.equals("N")) {
			source = "news";
		} else if (sns.equals("T")) {
			source = "twitter";
		} 
		
		
		// period >> 0 : 일별, 1 : 주별,2 : 월별, 3 : 분기,4 : 반기, 5 : 연간
		 
		String urlKeyword = "&keyword=" + URLEncoder.encode(keyword);
		String urlBasicTm2Condition = "lang=ko&command=GetTopAssocSentimentByPeriod&topN=100&cutOffFrequencyMin=0&cutOffFrequencyMax=0&start_weekday=SUNDAY&categorySetName=SM&invertRowCol=on&outputOption%5B%5D=freq";
		String urlSource = "&source=" + source; // insta, blog, twitter, news ...
		String urlStartDate = "&startDate=" + startDate;
		String urlEndDate = "&endDate=" + endDate;
		String urlPeriod = "&period=" + "2";
		
		String keywordUrl = tm2Url + urlBasicTm2Condition
									+ urlKeyword
									+ urlSource
									+ urlStartDate 
									+ urlEndDate
									+ urlPeriod;
		
		return keywordUrl;
	}
	

	private JSONObject getSenetimentData(String keyword, String dataStr, Map<String,Object> sentimentRatio) {
		
		JSONObject result = new JSONObject();
		
		try{
			
			// Json parser를 만들어 만들어진 문자열 데이터를 객체화 합니다. 
			JSONParser parser = new JSONParser(); 
			JSONObject obj = (JSONObject) parser.parse(dataStr); 
			
			JSONArray rows = (JSONArray) obj.get("rows"); 
			JSONObject row = (JSONObject) rows.get(0); 
			
			JSONObject assocData;
			String label;
			Long frequency;
			String polarity;

			JSONArray positiveDataList = new JSONArray();
			JSONArray negativeDataList = new JSONArray();

			for (int i = 1; i < 101; i++) { 
				
				assocData = (JSONObject)row.get("rank" + i);
				// {"label":"행복한","frequency":173,"score":109.59175,"polarity":"positive"}

				if (assocData == null) {
					break;
				}
				
				label = (String)assocData.get("label");
				frequency = (Long)assocData.get("frequency");
				polarity = (String)assocData.get("polarity");

				if (polarity.equals("positive") && positiveDataList.size() < 5) {
				
					JSONObject data = new JSONObject();
					
					data.put("index", positiveDataList.size());
					data.put("label", label);
					data.put("frequency", frequency);
					data.put("polarity", polarity);
					
					positiveDataList.add(data);
				} else if (polarity.equals("negative") && negativeDataList.size() < 5) {
				
					JSONObject data = new JSONObject();

					data.put("index", negativeDataList.size());
					data.put("label", label);
					data.put("frequency", frequency);
					data.put("polarity", polarity);
					
					negativeDataList.add(data);
					
				} else if (positiveDataList.size() >= 5 && negativeDataList.size() >= 5) {
					break;
				}
			}
			
			
			double positiveRatio = (double)(Long)sentimentRatio.get("positive");
			double negativeRatio = (double)(Long)sentimentRatio.get("negative");
			
			JSONObject positive = new JSONObject();
			positive.put("ratio", Math.round((positiveRatio/(positiveRatio+negativeRatio))*1000)/1000.0);
			positive.put("assoc", positiveDataList);
			result.put("positive", positive);
			
			JSONObject negative = new JSONObject();
			negative.put("ratio", Math.round((negativeRatio/(positiveRatio+negativeRatio))*1000)/1000.0);
			negative.put("assoc", negativeDataList);
			result.put("negative", negative);
			
			/*
			 {
					"positive":{
						"ratio":0.6,
						"assoc":[
					        {"index":0.3, "value":39, "fill":"#3366cc", "label":"긍정어1"},
					        {"index":0.4, "value":32, "fill":"#5c85d6", "label":"긍정어2"},
					        {"index":0.5, "value":19, "fill":"#85a3e0", "label":"긍정어3"},
					        {"index":0.6, "value":7, "fill":"#adc2eb", "label":"긍정어4"},
					        {"index":0.7, "value":3, "fill":"#c2d1f0", "label":"긍정어5"}
					    ]
					},
					"negative":{
						"ratio":0.4,
						"assoc":[
					        {"index":0.3, "value":39, "fill":"#ff3333", "label":"부정어1"},
					        {"index":0.4, "value":32, "fill":"#ff8080", "label":"부정어2"},
					        {"index":0.5, "value":19, "fill":"#ffb3b3", "label":"부정어3"},
					        {"index":0.6, "value":7, "fill":"#ffcccc", "label":"부정어4"},
					        {"index":0.7, "value":3, "fill":"#ffe6e6", "label":"부정어5"}
					    ]
					}
				}; 
			 
			 */
			
		}catch(Exception e){ 
			System.out.println(e.getMessage()); 
		}
		
		return result;
	}
	
	private String readURL(String kewordUrl) {
		
		BufferedReader br = null;
		String DataStr = "";
        String DataLine = "";
		
        try{            
        	// Web to Web
            URL url = new URL(kewordUrl);
            HttpURLConnection urlconnection = (HttpURLConnection) url.openConnection();
            urlconnection.setRequestMethod("GET");
            br = new BufferedReader(new InputStreamReader(urlconnection.getInputStream(),"UTF-8"));
            
            if ((DataLine = br.readLine()) == null) {
            	return null;
            }
            
            while(DataLine != null) {
            	DataStr = DataStr + DataLine + "\n";
            	DataLine = br.readLine();
            }
            
            br.close();
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return DataStr;
	}
}
