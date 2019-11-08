package com.example.demo.controller;

import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.service.TM2Service;

import jline.internal.Log;

@Controller
@RequestMapping("/d3")
public class D3Controller {
	@Autowired
	TM2Service tm2Service;
	
	@RequestMapping("/chart")
	public String showChart(String keyword, Model model) {
		
		if (keyword == null || keyword.trim().length() == 0) {
			model.addAttribute("alertMsg","키워드를 입력해주세요");
			model.addAttribute("historyBack","true");
			
			return "common/redirect";
		}
		
		model.addAttribute("keyword", keyword);
		
		JSONArray jsonResult = tm2Service.getKeywordMonthlyData(keyword);
		
		if (jsonResult == null) {
			
			model.addAttribute("alertMsg","서버 오류");
			model.addAttribute("historyBack","true");
			
			return "common/redirect";
			
		} else if (jsonResult.size() < 1){
			
			model.addAttribute("alertMsg","분석 정보가 없음");
			model.addAttribute("historyBack","true");
			
			return "common/redirect";
			
		}
		
		model.addAttribute("data", jsonResult);
		
		return "d3/chart";
	}

	@RequestMapping("/assocSentimentChart")
	public String showAssocSentimentChart(@RequestParam Map<String, Object> param, Model model) {
		
		String keyword = (String)param.get("keyword");
		String analysisDate = (String)param.get("analysisDate");

		JSONObject jsonResult = tm2Service.getAssocSentimnetData(keyword, analysisDate);
		
		if (jsonResult == null || jsonResult.size() < 1){
			
			return null;
			
		}
		
		model.addAttribute("data", jsonResult);
		
		return "d3/assocSentimentChart";
	}
}
