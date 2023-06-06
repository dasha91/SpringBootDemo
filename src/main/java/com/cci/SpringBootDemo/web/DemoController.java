package com.cci.SpringBootDemo.web;

import com.cci.SpringBootDemo.entity.Application;
import com.cci.SpringBootDemo.service.ApplicationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

@Controller
public class DemoController {
    private ApplicationService applicationService;

    @Autowired
    public void setApplicationService(ApplicationService applicationService) {
        this.applicationService = applicationService;
    }


    @GetMapping("/")
    public String retrieveApplications(Model model){
        model.addAttribute("applications", applicationService.listApplications());
        model.addAttribute("application", new Application());
        return "index";
    }

    @PostMapping("/")
    public String applicationSubmit(@ModelAttribute Application application, Model model) {
        System.out.println(application.toString());
        application.setId(1L);
        model.addAttribute("applications", applicationService.update(application));
        return "index";
    }
}