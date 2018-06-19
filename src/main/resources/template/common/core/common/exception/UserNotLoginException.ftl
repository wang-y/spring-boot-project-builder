package ${corepackage}.common.exception;

/**
 * Description:
 *  用户未登录
 */
public class UserNotLoginException extends BusinessException {
    private static final long serialVersionUID = -1879503946782379204L;

    public UserNotLoginException() {
        super();
    }

    public UserNotLoginException(String msg) {
        super(msg);
    }

    public UserNotLoginException(String formatMsg, Object... objects) {
        super(formatMsg, objects);
    }

}
