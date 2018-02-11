package ${corepackage}.page;

import java.io.Serializable;

public class PageInfo implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = 5973539372078187514L;

    private long totalSize;

    private long totalPage;

    private Integer pageSize;

    private int startRecord;

    private int currentPage; //当前页码

    private boolean isFirstPage; // 是否为第一页

    private boolean isLastPage; // 是否为最后一页

    private boolean hasPreviousPage; // 是否有前一页

    private boolean hasNextPage; // 是否有下一页



    public PageInfo(long totalSize, Integer pageSize) {
        if (pageSize == null) {
            pageSize = 20;
        }
        this.totalSize = totalSize;
        this.pageSize = pageSize;

        if (totalSize == 0) {
            this.setTotalPage(1);
        }
        this.setTotalPage(totalSize % pageSize == 0 ? totalSize / pageSize : totalSize / pageSize + 1);
    }

    public PageInfo(long totalSize, Integer pageSize, Integer pageNum) {
        if (pageSize == null) {
            pageSize = 20;
        }
        this.totalSize = totalSize;
        this.pageSize = pageSize;

        if (totalSize == 0) {
            this.setTotalPage(1);
        }
        this.setTotalPage(totalSize % pageSize == 0 ? totalSize / pageSize : totalSize / pageSize + 1);
        this.refresh(pageNum);
    }

    public int getStartRecord() {
        return startRecord;
    }

    public ${corepackage}.page.PageInfo refresh(Integer pageNum) {
        if (pageNum == null || this.pageSize == null) {
            this.startRecord = 0;
        } else {
            this.startRecord = (pageNum - 1) * this.pageSize;
        }
        this.currentPage = pageNum;
        this.isFirstPage = pageNum == 1;
        this.isLastPage = this.totalPage == 0 || pageNum == this.totalPage;
        this.hasPreviousPage = pageNum > 1;
        this.hasNextPage = pageNum < this.totalPage;
        return this;
    }

    public long getTotalSize() {
        return totalSize;
    }

    public void setTotalSize(int totalSize) {
        this.totalSize = totalSize;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }

    public long getTotalPage() {
        return totalPage;
    }

    public void setTotalPage(long totalPage) {
        this.totalPage = totalPage;
    }

    public boolean isFirstPage() {
        return isFirstPage;
    }

    public void setFirstPage(boolean isFirstPage) {
        this.isFirstPage = isFirstPage;
    }

    public boolean isLastPage() {
        return isLastPage;
    }

    public void setLastPage(boolean isLastPage) {
        this.isLastPage = isLastPage;
    }

    public boolean isHasPreviousPage() {
        return hasPreviousPage;
    }

    public void setHasPreviousPage(boolean hasPreviousPage) {
        this.hasPreviousPage = hasPreviousPage;
    }

    public boolean isHasNextPage() {
        return hasNextPage;
    }

    public void setHasNextPage(boolean hasNextPage) {
        this.hasNextPage = hasNextPage;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }
}
