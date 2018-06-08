package ${corepackage}.web;

import ${corepackage}.common.PageRequest;
import ${corepackage}.common.PostRequest;
import ${corepackage}.common.Result;
import ${corepackage}.common.ResultGenerator;
import ${corepackage}.page.SimplePage;
import ${corepackage}.service.IBasicService;
<#if enabledSwagger>
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
</#if>
import org.springframework.web.bind.annotation.*;

import java.io.Serializable;
import java.util.Collection;

public abstract class BasicController<V extends Serializable, E extends Serializable, ID extends Serializable> {

    protected abstract IBasicService<V, E, ID> getService();

<#if enabledSwagger>
    @ApiOperation(value = "详情", notes = "根据主键查询详情")
</#if>
    @GetMapping(value = "/{id}")
    public Result<V> getOne(@ApiParam(required = true, value = "主键") @PathVariable ID id) {
        return ResultGenerator.genSuccessResult(getService().findOne(id));
    }

<#if enabledSwagger>
    @ApiOperation(value = "详情", notes = "根据条件查询详情")
    @ApiImplicitParam(name = "request", required = true, dataType = "PostRequest", paramType = "body")
</#if>
    @PostMapping(value = "find")
    public Result<V> find(@ApiParam @RequestBody PostRequest request) {
        return ResultGenerator.genSuccessResult(getService().findOne(request.getQueryParams()));
    }

<#if enabledSwagger>
    @ApiOperation(value = "列表", notes = "根据条件查询分页列表")
    @ApiImplicitParam(name = "request", required = true, dataType = "PageRequest", paramType = "body")
</#if>
    @PostMapping(value = "page")
    public Result<SimplePage<V>> page(@RequestBody PageRequest request) {
        return ResultGenerator.genSuccessResult(getService().page(request.getQueryParams(), request.getOrderBy(), request.getPage(), request.getSize()));
    }

<#if enabledSwagger>
    @ApiOperation(value = "列表", notes = "根据条件查询不分页列表")
    @ApiImplicitParam(name = "request", required = true, dataType = "PostRequest", paramType = "body")
</#if>
    @PostMapping(value = "list")
    public Result<Collection<V>> list(@RequestBody PostRequest request) {
        return ResultGenerator.genSuccessResult(getService().list(request.getQueryParams(), request.getOrderBy()));
    }

<#if enabledSwagger>
    @ApiOperation(value = "新增", notes = "添加新数据")
</#if>
    @PostMapping
    public Result<V> add(@RequestBody V v) {
        return ResultGenerator.genSuccessResult(getService().save(v));
    }

<#if enabledSwagger>
    @ApiOperation(value = "修改", notes = "修改数据")
</#if>
    @PutMapping
    public Result<V> modify(@RequestBody V v) {
        return ResultGenerator.genSuccessResult(getService().update(v));
    }

<#if enabledSwagger>
    @ApiOperation(value = "删除", notes = "根据主键删除数据")
</#if>
    @DeleteMapping(value = "/{id}")
    public Result<Void> del(@ApiParam(required = true, value = "主键") @PathVariable ID id) {
        getService().delByID(id);
        return ResultGenerator.genSuccessResult();
    }

<#if enabledSwagger>
    @ApiOperation(value = "删除", notes = "根据主键集合批量删除数据")
</#if>
    @DeleteMapping
    public Result<Void> del(@ApiParam(required = true, value = "主键集合") @RequestParam Collection<ID> ids) {
        getService().delBatchByID(ids);
        return ResultGenerator.genSuccessResult();
    }

}
