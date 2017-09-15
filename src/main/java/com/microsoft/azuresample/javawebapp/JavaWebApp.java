package com.microsoft.azuresample.javawebapp;

import com.microsoft.applicationinsights.web.internal.WebRequestTrackingFilter;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.support.SpringBootServletInitializer;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Configuration
@ComponentScan
@EnableAutoConfiguration
public class JavaWebApp extends SpringBootServletInitializer {
    static final Logger LOG = LoggerFactory.getLogger(JavaWebApp.class);
    
    public static void main(String[] args) {
        ApplicationContext ctx = SpringApplication.run(JavaWebApp.class, args);
        LOG.info("My Spring Boot app started ...");
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(applicationClass);
    }

    private static Class<JavaWebApp> applicationClass = JavaWebApp.class;

    @Bean
    public FilterRegistrationBean filterRegistrationBean() {
        final FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
        final WebRequestTrackingFilter webRequestTrackingFilter = new WebRequestTrackingFilter();
        filterRegistrationBean.setFilter(webRequestTrackingFilter);
        return filterRegistrationBean;
    }
}
