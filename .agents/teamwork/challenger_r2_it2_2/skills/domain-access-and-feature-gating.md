# Domain Skill: Tiered Access Control & Feature Gating (Local Copy)

Source: `/Users/whykrr/Documents/Projects/Laravel/sollu-app/.agents/skills/domain-access-and-feature-gating/SKILL.md`

## Key Formula:
CanAccess(user, feature, action) = IsFeatureActive(business, feature) AND HasPermission(user, action) AND IsOutletOperational(outlet)

## 6-Layer Gating Stack:
- Layer 0: Tenant & Subscription Lifecycle
- Layer 1: Business Type Capability Gating
- Layer 2: SaaS Plan Feature Gating (SubscriptionPlan::activeFeatureEnums(), PlanEnum: Micro, Basic, Pro)
- Layer 3: Merchant Feature Personalization (settings['active_features'])
- Layer 4: Outlet & Device Operational Guards
- Layer 5: User Role-Based Access Control (RBAC, PermissionEnum)

## Enforcement:
- Plan Feature Gating: `plan.feature:feature_name` middleware -> HTTP 403 `{"is_feature_locked": true, "feature": "..."}` or redirect with flash `feature_locked`.
- RBAC: `FormRequest::authorize()` or controller `$this->authorize(...)` -> HTTP 403 `{"message": "This action is unauthorized."}`.
