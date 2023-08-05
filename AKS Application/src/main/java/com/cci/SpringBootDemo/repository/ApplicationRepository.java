package com.cci.SpringBootDemo.repository;

import com.cci.SpringBootDemo.entity.Application;
import org.springframework.data.repository.CrudRepository;

public interface ApplicationRepository extends CrudRepository<Application, Long> {
}
