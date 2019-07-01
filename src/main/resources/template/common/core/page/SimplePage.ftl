package ${corepackage}.page;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Stream;

public class SimplePage<T> implements Iterable<T>, Serializable {

	private static final long serialVersionUID = 8630682834277688044L;

	private PageInfo pageInfo;

	private List<T> result;

	public SimplePage() {
	    this.result = new ArrayList<T>();
	}

	public SimplePage(PageInfo pageInfo) {
	    this.pageInfo = pageInfo;
	    this.result = new ArrayList<T>();
	}

	public SimplePage(PageInfo pageInfo, List<T> result) {
	    this.pageInfo = pageInfo;
	    this.result = result;
	}

	public PageInfo getPageInfo() {
	    return pageInfo;
	}

	public void setPageInfo(PageInfo pageInfo) {
	    this.pageInfo = pageInfo;
	}

	public List<T> getResult() {
	    return result;
	}

	public void setResult(List<T> result) {
	    this.result = result;
	}

	public int resultSize() {
	    return result.size();
	}

	public boolean isEmpty() {
	    return result.isEmpty();
	}

	public void addResult(T t) {
	    this.result.add(t);
	}

	public void addResults(List<T> result) {
	    this.result.addAll(result);
	}

	@Override
	public Iterator<T> iterator() {
	    return new ListIterator();
	}

    	// 实现Iterator接口的私有内部类，外界无法直接访问
    	private class ListIterator implements Iterator <T> {
            // 当前迭代元素的下标
            private int index = 0;

            // 判断是否还有下一个元素，如果迭代到最后一个元素就返回false
            public boolean hasNext() {
                return index != resultSize();
            }

            // 返回当前元素数据，并递增下标
            public T next() {
                return result.get(index++);
            }

            // 这里不支持，抛出不支持操作异常
            public void remove() {
                throw new UnsupportedOperationException();
            }
        }

    public Stream<T> stream() {
       return  this.result.stream();
    }

}
