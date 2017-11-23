package sojamo.drop;

import java.awt.Component;
import java.awt.dnd.DropTarget;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Vector;

/**
 * sojamo.drop is a processing and java library for dragging and dropping
 * things over an awt window.
 *
 *  2007 by Andreas Schlegel
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author Andreas Schlegel (http://www.sojamo.de)
 *
 */

/**
 * sojamo.drop is a processing library that lets you drag and drop objects such
 * as files, images, bookmarks, or text into your processing application. once
 * dropped you can access the information of the object from a DropEvent that
 * has been forwarded to the processing sketch.
 *
 * @example dropBasics
 */
public class SDrop {

	private Method _myMethod;

	protected Component component;

	protected Object parent;

	private String _myMethodName;

	private Class _myParameterClass;

	private boolean isReflection;

	/**
	 * @invisible
	 */
	public static boolean DEBUG = false;

	protected Vector _myDropListener;

	private final DropHandler myDropHandler;

	/**
	 * @invisible
	 */
	public final static String VERSION = "0.1.4";

	/**
	 * in processing you instantiate SDrop with drop = new SDrop(this);
	 *
	 * @param theComponent
	 */
	public SDrop(Component theComponent) {
		this(theComponent, theComponent);
	}

	/**
	 *
	 * @param theComponent
	 * @param theObject
	 */
	public SDrop(Component theComponent, Object theObject) {
		_myDropListener = new Vector();
		component = theComponent;
		parent = theObject;
		Class myClass = parent.getClass();
		_myMethodName = "dropEvent";

		try {
			Method[] myMethods = myClass.getDeclaredMethods();
			for (int i = 0; i < myMethods.length; i++) {
				if ((myMethods[i].getName()).equals(_myMethodName)) {
					if (myMethods[i].getParameterTypes().length == 1) {
						if (myMethods[i].getParameterTypes()[0] == sojamo.drop.DropEvent.class) {
							_myParameterClass = sojamo.drop.DropEvent.class;
						}
					}
				}
			}
			Class[] myArgs = (_myParameterClass == null) ? new Class[] {}
					: new Class[] { _myParameterClass };
			_myMethod = myClass.getDeclaredMethod(_myMethodName, myArgs);
			_myMethod.setAccessible(true);
			isReflection = true;
		} catch (SecurityException e) {
		} catch (NoSuchMethodException e) {
		}
		myDropHandler = new DropHandler(this);
		addComponent(theComponent);
		welcome();
	}

	private void welcome() {
		System.out.println("sojamo.drop " + VERSION + " "
				+ "infos, comments, questions at http://www.sojamo.de/libraries/drop");
	}

	/**
	 * if you combine sojamo.drop with e.g. a control window from controlP5 you
	 * can add a control window asa component to sojamo.drop. objects dropped
	 * into the component, here control window ,will be forwarded to your
	 * processing sketch.
	 *
	 * @param theComponent
	 *            Component
	 */
	public void addComponent(Component theComponent) {
		new DropTarget(theComponent, myDropHandler);
	}

	/**
	 * add a drop listener to your sketch.
	 *
	 * @example dropListener
	 * @param theListener
	 *            DropListener
	 */
	public void addDropListener(DropListener theListener) {
		_myDropListener.add(theListener);
	}

	/**
	 * remove a drop listener from your sketch.
	 *
	 * @example dropListener
	 * @param theListener
	 *            DropListener
	 */
	public void removeDropListener(DropListener theListener) {
		_myDropListener.remove(theListener);
	}

	protected Vector getDropListeners() {
		return _myDropListener;
	}
  protected void dragExit(){
		for (int i = (_myDropListener.size() - 1); i >= 0; i--) {
			//if (((DropListener) _myDropListener.get(i)).isSpecificTargetLocation) {
				((DropListener) _myDropListener.get(i)).dragExit();
			//}
		}
  }
	protected void updateDropListener(float theX, float theY) {
		for (int i = (_myDropListener.size() - 1); i >= 0; i--) {
			//if (((DropListener) _myDropListener.get(i)).isSpecificTargetLocation) {
				((DropListener) _myDropListener.get(i)).updateLocation(theX, theY);
			//}
		}
	}

	/**
	 * @invisible
	 * @param theDropEvent
	 *            DropEvent
	 */
	protected void invokeDropEvent(DropEvent theDropEvent) {
		if (isReflection) {
			try {
				_myMethod.invoke(parent, new Object[] { theDropEvent });
			} catch (IllegalArgumentException e) {
				System.out.println("### ERROR @ sojamo.drop.invokeMethod " + _myMethod.toString()
						+ "  " + _myMethod.getName() + " / " + e);
			} catch (IllegalAccessException e) {
			} catch (InvocationTargetException e) {
			} catch (NullPointerException e) {
			}
		}

		for (int i = (_myDropListener.size() - 1); i >= 0; i--) {
			if (((DropListener) _myDropListener.get(i)).isSpecificTargetLocation) {
				if (((DropListener) _myDropListener.get(i)).isInside(theDropEvent.x(), theDropEvent
						.y())) {
					((DropListener) _myDropListener.get(i)).dropEvent(theDropEvent);
				}
			} else {
				((DropListener) _myDropListener.get(i)).dropEvent(theDropEvent);
			}
			((DropListener) _myDropListener.get(i)).dropFinished();
		}
		System.gc();

	}


  public static void main(String[] args) {
  }}
