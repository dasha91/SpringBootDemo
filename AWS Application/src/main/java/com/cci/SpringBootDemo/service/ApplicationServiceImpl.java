package com.cci.SpringBootDemo.service;

import com.cci.SpringBootDemo.entity.Application;
import com.cci.SpringBootDemo.repository.ApplicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ApplicationServiceImpl implements ApplicationService {
    @Autowired
    private ApplicationRepository applicationRepository;

    @Override
    public Iterable<Application> listApplications() {
        return applicationRepository.findAll();
    }

    public Iterable<Application> update(Application app){
        applicationRepository.save(app);
        return applicationRepository.findAll();
    }

}
