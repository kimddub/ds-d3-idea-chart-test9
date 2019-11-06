package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class D3Controller {

	@RequestMapping("/")
	public String showD3chart() {
		return "d3chart";
	}
}
