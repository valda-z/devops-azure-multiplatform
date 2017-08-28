package com.microsoft.azuresample.javawebapp.model;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Created by vazvadsk on 2016-12-02.
 */
public class ToDo {
    private String id;
    private String comment;
    private String category;
    private Date created;
    private Date updated;
    
    public ToDo(){

    }

    public ToDo(String id, String comment, String category, Date created, Date updated){
        this.setId(id);
        this.setComment(comment);
        this.setCategory(category);
        this.setCreated(created);
        this.setUpdated(updated);
    }

    @JsonProperty("id")
    public String getId() {
        return id;
    }

    @JsonProperty("id")
    public void setId(String id) {
        this.id = id;
    }

    @JsonProperty("comment")
    public String getComment() {
        return comment;
    }

    @JsonProperty("comment")
    public void setComment(String comment) {
        this.comment = comment;
    }

    @JsonProperty("category")
    public String getCategory() {
        return category;
    }

    @JsonProperty("category")
    public void setCategory(String category) {
        this.category = category;
    }

    @JsonProperty("created")
    public Date getCreated() {
        return created;
    }

    @JsonProperty("created")
    public void setCreated(Date created) {
        this.created = created;
    }

    @JsonProperty("updated")
    public Date getUpdated() {
        return updated;
    }

    @JsonProperty("updated")
    public void setUpdated(Date updated) {
        this.updated = updated;
    }

}
