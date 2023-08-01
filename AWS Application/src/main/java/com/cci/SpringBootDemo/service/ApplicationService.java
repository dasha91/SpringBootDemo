package com.cci.SpringBootDemo.service;

import com.cci.SpringBootDemo.entity.Application;

public interface ApplicationService {
    Iterable<Application> listApplications();
    Iterable<Application> update(Application app);
}


