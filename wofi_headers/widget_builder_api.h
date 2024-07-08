/*
 *  Copyright (C) 2020-2022 Scoopta
 *  This file is part of Wofi
 *  Wofi is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Wofi is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Wofi.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef WIDGET_BUILDER_API_H
#define WIDGET_BUILDER_API_H

#include <stddef.h>

#include <wofi_api.h>

#include <gdk-pixbuf/gdk-pixbuf.h>

struct css_class {
	char* class;
	struct wl_list link;
};

struct widget_builder* wofi_widget_builder_init(struct mode* mode, size_t actions);

void wofi_widget_builder_set_search_text(struct widget_builder* builder, char* search_text);

void wofi_widget_builder_set_action(struct widget_builder* builder, char* action);

__attribute__((sentinel)) void wofi_widget_builder_insert_text(struct widget_builder* builder, const char* text, ...);

void wofi_widget_builder_insert_text_with_list(struct widget_builder* builder, const char* text, struct wl_list* classes);

__attribute__((sentinel)) void wofi_widget_builder_insert_image(struct widget_builder* builder, GdkPixbuf* pixbuf, ...);

void wofi_widget_builder_insert_image_with_list(struct widget_builder* builder, GdkPixbuf* pixbuf, struct wl_list* classes);

struct widget_builder* wofi_widget_builder_get_idx(struct widget_builder* builder, size_t idx);

struct widget* wofi_widget_builder_get_widget(struct widget_builder* builder);

void wofi_widget_builder_free(struct widget_builder* builder);

#endif
