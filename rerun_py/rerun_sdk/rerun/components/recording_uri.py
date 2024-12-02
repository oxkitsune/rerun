# DO NOT EDIT! This file was auto-generated by crates/build/re_types_builder/src/codegen/python/mod.rs
# Based on "crates/store/re_types/definitions/rerun/components/recording_uri.fbs".

# You can extend this class by creating a "RecordingUriExt" class in "recording_uri_ext.py".

from __future__ import annotations

from .. import datatypes
from .._baseclasses import (
    ComponentBatchMixin,
    ComponentMixin,
)

__all__ = ["RecordingUri", "RecordingUriBatch"]


class RecordingUri(datatypes.Utf8, ComponentMixin):
    """**Component**: A recording URI (Uniform Resource Identifier)."""

    _BATCH_TYPE = None
    # You can define your own __init__ function as a member of RecordingUriExt in recording_uri_ext.py

    # Note: there are no fields here because RecordingUri delegates to datatypes.Utf8
    pass


class RecordingUriBatch(datatypes.Utf8Batch, ComponentBatchMixin):
    _COMPONENT_NAME: str = "rerun.components.RecordingUri"


# This is patched in late to avoid circular dependencies.
RecordingUri._BATCH_TYPE = RecordingUriBatch  # type: ignore[assignment]