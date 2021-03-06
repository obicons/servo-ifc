/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// https://html.spec.whatwg.org/multipage/#htmloptionscollection
[Exposed=Window]
interface HTMLOptionsCollection : HTMLCollection {
  // inherits item(), namedItem()
  [CEReactions]
  attribute unsigned long length; // shadows inherited length
  [CEReactions, Throws]
  setter undefined (unsigned long index, HTMLOptionElement? option);
  [CEReactions, Throws]
  undefined add((HTMLOptionElement or HTMLOptGroupElement) element, optional (HTMLElement or long)? before = null);
  [CEReactions]
  undefined remove(long index);
  attribute long selectedIndex;
};
