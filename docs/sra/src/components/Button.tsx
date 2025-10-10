import React, { CSSProperties, useEffect } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import { useColorMode } from '@docusaurus/theme-common';

type Button = {
    size?: 'sm' | 'lg' | 'small' | 'medium' | 'large' | null;
    outline?: boolean;
    variant: 'primary' | 'secondary' | 'danger' | 'warning' | 'success' | 'info' | 'link' | string;
    block?: boolean;
    disabled?: boolean;
    className?: string;
    style?: CSSProperties;
    link: string;
    label: string;
    linkClassName?: string;
};

export default function Button(props: Button) {
    const {
        size = null,
        outline = false,
        variant = 'primary',
        block = false,
        disabled = false,
        className,
        style,
        link,
        label,
        linkClassName,
    } = props;

    const { colorMode } = useColorMode();

    // Inject hover style once
    useEffect(() => {
        const styleId = 'custom-button-hover-style';
        if (!document.getElementById(styleId)) {
            const styleTag = document.createElement('style');
            styleTag.id = styleId;
            styleTag.innerHTML = `
                .btn--custom:hover:not(:disabled) {
                    background-color: #FF5F46 !important;
                    color: #fff !important;
                }
            `;
            document.head.appendChild(styleTag);
        }
    }, []);

    // Map size props to class names
    const sizeMap: Record<string, string | null> = {
        sm: 'sm',
        small: 'sm',
        lg: 'lg',
        large: 'lg',
        medium: null,
    };
    const buttonSize = size ? sizeMap[size] : '';
    const sizeClass = buttonSize ? `button--${buttonSize}` : '';
    const outlineClass = outline ? 'button--outline' : '';
    const variantClass = variant ? `button--${variant}` : '';
    const blockClass = block ? 'button--block' : '';
    const disabledClass = disabled ? 'disabled' : '';
    const destination = disabled ? null : link;

    // Choose color based on colorMode
    const isDark = colorMode === 'dark';
    const colorStyles: CSSProperties = {
        backgroundColor: isDark ? '#fff' : '#f0f0f0',
        color: isDark ? '#000' : '#000',
        border: 'none',
        ...style,
    };

    return (
        <Link to={destination} className={linkClassName}>
            <button
                className={clsx(
                    'btn',
                    'btn--custom',
                    'button',
                    sizeClass,
                    outlineClass,
                    variantClass,
                    blockClass,
                    disabledClass,
                    className
                )}
                style={colorStyles}
                role='button'
                aria-disabled={disabled}
                disabled={disabled}
            >
                {label}
            </button>
        </Link>
    );
}