package com.example.demo.service;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public interface TM2Service {

	public JSONArray getKeywordMonthlyData(String keyword);

	public JSONObject getAssocSentimnetData(String keyword, String analysisDate);





}
