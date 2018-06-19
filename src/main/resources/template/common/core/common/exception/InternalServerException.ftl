package ${corepackage}.common.exception;

/**
 * Description:
 *  系统内部错误
 */
public class InternalServerException extends BusinessException {
    private static final long serialVersionUID = 2659909836556958676L;

    public InternalServerException() {
        super();
    }

    public InternalServerException(String msg, Throwable cause) {
        super(msg, cause);
    }

    public InternalServerException(String msg, Throwable cause, Object... objects) {
        super(msg, cause, objects);
    }

    public InternalServerException(String msg) {
        super(msg);
    }

    public InternalServerException(String formatMsg, Object... objects) {
        super(formatMsg, objects);
    }

}
