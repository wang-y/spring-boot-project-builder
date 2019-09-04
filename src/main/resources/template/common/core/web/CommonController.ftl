package ${corepackage}.web;

<#if enabledSwagger>
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
</#if>
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import ${corepackage}.common.body.PageRequest;
import ${corepackage}.common.body.PostRequest;
import ${corepackage}.common.result.ResponseResult;
import ${corepackage}.page.SimplePage;
import ${corepackage}.service.IService;

import java.io.Serializable;
import java.util.Collection;

@ResponseResult
public abstract class CommonController<E,ID extends Serializable,SERVICE extends IService<E,ID>> {

    @Autowired
    protected SERVICE service;

<#if enabledSwagger>
    @ApiOperation(value = "详情", notes = "根据主键查询详情")
</#if>
    @GetMapping(value = "{id}")
    public E getOne(@ApiParam(required = true, value = "主键") @PathVariable ID id) {
        return service.findOne(id);
    }

<#if enabledSwagger>
    @ApiOperation(value = "详情", notes = "根据条件查询详情")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "queryParams", value = "按照json 格式填写", dataType = "String", paramType = "query"),
            @ApiImplicitParam(name = "orderBy", value = "按照json 格式填写", dataType = "String", paramType = "query")
    })
</#if>
    @GetMapping(value = "find")
    public E find(PostRequest request) {
        return service.findOne(request.getQueryParams());
    }

<#if enabledSwagger>
    @ApiOperation(value = "分页列表", notes = "根据条件查询分页列表")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "queryParams", value = "按照json 格式填写", dataType = "String", paramType = "query"),
            @ApiImplicitParam(name = "orderBy", value = "按照json 格式填写", dataType = "String", paramType = "query"),
            @ApiImplicitParam(name = "page", value = "当前页", dataType = "Integer", paramType = "query"),
            @ApiImplicitParam(name = "size", value = "当前页显示条数", dataType = "Integer", paramType = "query")
    })
</#if>
    @GetMapping(value = "page")
    public SimplePage<E> page(PageRequest request) {
        return service.page(request.getQueryParams(), request.getOrderBy(), request.getPage(), request.getSize());
    }

<#if enabledSwagger>
    @ApiOperation(value = "列表", notes = "根据条件查询列表")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "queryParams", value = "按照json 格式填写", dataType = "String", paramType = "query"),
            @ApiImplicitParam(name = "orderBy", value = "按照json 格式填写", dataType = "String", paramType = "query")
    })
</#if>
    @GetMapping(value = "list")
    public Collection<E> list(PostRequest request) {
        return service.list(request.getQueryParams(), request.getOrderBy());
    }

<#if enabledSwagger>
    @ApiOperation(value = "新增", notes = "添加新数据")
</#if>
    @PostMapping
    public E add(@RequestBody E e) {
        return service.save(e);
    }

<#if enabledSwagger>
    @ApiOperation(value = "修改", notes = "修改数据")
</#if>
    @PutMapping
    public E modify(@RequestBody E e) {
        return service.update(e);
    }

<#if enabledSwagger>
    @ApiOperation(value = "删除", notes = "根据主键删除数据")
</#if>
    @DeleteMapping(value = "{id}")
    public void del(@ApiParam(required = true, value = "主键") @PathVariable ID id) {
        service.delByID(id);
    }

<#if enabledSwagger>
    @ApiOperation(value = "删除", notes = "根据主键集合批量删除数据")
</#if>
    @DeleteMapping
    public void del(@ApiParam(required = true, value = "主键集合") @RequestParam Collection<ID> ids) {
        service.delBatchByID(ids);
    }

}
